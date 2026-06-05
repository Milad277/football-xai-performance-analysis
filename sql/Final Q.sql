WITH
-- 1) میزبان/میهمان و گل‌ها
team_sides AS (
    SELECT 
        mt.matchId,
        MAX(CASE WHEN mt.side='home' THEN mt.teamId END) AS homeTeamId,
        MAX(CASE WHEN mt.side='away' THEN mt.teamId END) AS awayTeamId,
        MAX(CASE WHEN mt.side='home' THEN mt.score END)  AS homeGoals,
        MAX(CASE WHEN mt.side='away' THEN mt.score END)  AS awayGoals
    FROM match_teams mt
    GROUP BY mt.matchId
),

-- 2) assists تیمی از lineup و bench
assists_by_team AS (
    SELECT
        matchId,
        teamId,
        SUM(COALESCE(assists,0)) AS assists
    FROM (
        SELECT matchId, teamId, assists FROM lineup
        UNION ALL
        SELECT matchId, teamId, assists FROM bench
    )
    GROUP BY matchId, teamId
),

-- 3) نقاط شروع/پایان هر رویداد
event_points AS (
    SELECT
        e.eventId,
        e.matchId,
        e.teamId,
        LOWER(TRIM(e.period))        AS period_str,           -- '1h' یا غیر از آن
        LOWER(TRIM(e.subEventName))  AS subEventName_norm,
        MAX(CASE WHEN ep.posOrder=0 THEN ep.x END) AS start_x,
        MAX(CASE WHEN ep.posOrder=0 THEN ep.y END) AS start_y,
        MAX(CASE WHEN ep.posOrder=1 THEN ep.x END) AS end_x,
        MAX(CASE WHEN ep.posOrder=1 THEN ep.y END) AS end_y
    FROM events e
    LEFT JOIN event_positions ep ON ep.eventId = e.eventId
    GROUP BY e.eventId, e.matchId, e.teamId
),

-- 4) نرمال‌سازی جهت حمله و تعیین ناحیه براساس end_x
event_points_norm AS (
    SELECT
        p.eventId, p.matchId, p.teamId, p.period_str, p.subEventName_norm,

        -- نرمال‌سازی: میزبان در '1h' همسو، میهمان در ≠'1h' همسو؛ دیگری معکوس
        CASE
          WHEN ((p.teamId = ts.homeTeamId AND p.period_str = '1h')
             OR (p.teamId = ts.awayTeamId AND p.period_str <> '1h'))
          THEN p.end_x ELSE 100.0 - p.end_x END AS end_x_norm,

        CASE
          WHEN ((p.teamId = ts.homeTeamId AND p.period_str = '1h')
             OR (p.teamId = ts.awayTeamId AND p.period_str <> '1h'))
          THEN p.start_x ELSE 100.0 - p.start_x END AS start_x_norm,

        p.start_y, p.end_y,

        -- تقسیم‌بندی زمین بر اساس end_x (ثلث دفاع/میانی/حمله برای تیم مالک رویداد)
        CASE
          WHEN ((p.teamId = ts.homeTeamId AND p.period_str = '1h')
             OR (p.teamId = ts.awayTeamId AND p.period_str <> '1h'))
          THEN
            CASE
              WHEN p.end_x < 33.333 THEN 'def'
              WHEN p.end_x < 66.666 THEN 'mid'
              ELSE 'att'
            END
          ELSE
            CASE
              WHEN (100.0 - p.end_x) < 33.333 THEN 'def'
              WHEN (100.0 - p.end_x) < 66.666 THEN 'mid'
              ELSE 'att'
            END
        END AS end_third
    FROM event_points p
    JOIN team_sides ts ON ts.matchId = p.matchId
),

-- 5) فیچرهای کلی (بدون تفکیک یک‌سوم)
sub_features AS (
    SELECT
        e.matchId,
        e.teamId,

        -- پاس‌ها
        SUM(CASE WHEN e.subEventName_norm='simple pass' THEN 1 ELSE 0 END) AS simple_passes,
        SUM(CASE WHEN e.subEventName_norm='high pass'   THEN 1 ELSE 0 END) AS high_passes,
        SUM(CASE WHEN e.subEventName_norm='smart pass'  THEN 1 ELSE 0 END) AS smart_passes,
        SUM(CASE WHEN e.subEventName_norm IN ('cross','free kick cross') THEN 1 ELSE 0 END) AS crosses,
        SUM(CASE WHEN e.subEventName_norm='head pass'   THEN 1 ELSE 0 END) AS head_passes,

        -- شوت‌ها
        SUM(CASE WHEN e.subEventName_norm='head shot'       THEN 1 ELSE 0 END) AS head_shots,
        SUM(CASE WHEN e.subEventName_norm='shot on target'  THEN 1 ELSE 0 END) AS on_target_shots,
        SUM(CASE WHEN e.subEventName_norm='shot off target' THEN 1 ELSE 0 END) AS off_target_shots,
        SUM(CASE WHEN e.subEventName_norm='free kick shot'  THEN 1 ELSE 0 END) AS free_kick_shots,
        SUM(CASE WHEN e.subEventName_norm IN ('penalty','penalty shot') THEN 1 ELSE 0 END) AS penalties,

        -- دفاعی
        SUM(CASE WHEN e.subEventName_norm='clearance'    THEN 1 ELSE 0 END) AS clearances,
        SUM(CASE WHEN e.subEventName_norm='interception' THEN 1 ELSE 0 END) AS interceptions,
        SUM(CASE WHEN e.subEventName_norm='tackle'       THEN 1 ELSE 0 END) AS tackles,

        -- ری‌استارت‌ها
        SUM(CASE WHEN e.subEventName_norm='corner'       THEN 1 ELSE 0 END) AS corners,
        SUM(CASE WHEN e.subEventName_norm IN ('throw in','throw-in') THEN 1 ELSE 0 END) AS throw_ins,
        SUM(CASE WHEN e.subEventName_norm='free kick cross' THEN 1 ELSE 0 END) AS free_kick_crosses,

        -- خطاها
        SUM(CASE WHEN e.subEventName_norm='hand foul' THEN 1 ELSE 0 END) AS hand_fouls
    FROM event_points_norm e
    GROUP BY e.matchId, e.teamId
),

-- 6) فیچرهای تفکیک‌شده براساس ناحیه پایان (end_third)
sub_features_thirds AS (
    SELECT
        e.matchId,
        e.teamId,

        -- Passes
        SUM(CASE WHEN e.subEventName_norm='simple pass' AND e.end_third='def' THEN 1 ELSE 0 END) AS simple_passes_def,
        SUM(CASE WHEN e.subEventName_norm='simple pass' AND e.end_third='mid' THEN 1 ELSE 0 END) AS simple_passes_mid,
        SUM(CASE WHEN e.subEventName_norm='simple pass' AND e.end_third='att' THEN 1 ELSE 0 END) AS simple_passes_att,

        SUM(CASE WHEN e.subEventName_norm='high pass' AND e.end_third='def' THEN 1 ELSE 0 END) AS high_passes_def,
        SUM(CASE WHEN e.subEventName_norm='high pass' AND e.end_third='mid' THEN 1 ELSE 0 END) AS high_passes_mid,
        SUM(CASE WHEN e.subEventName_norm='high pass' AND e.end_third='att' THEN 1 ELSE 0 END) AS high_passes_att,

        SUM(CASE WHEN e.subEventName_norm='smart pass' AND e.end_third='def' THEN 1 ELSE 0 END) AS smart_passes_def,
        SUM(CASE WHEN e.subEventName_norm='smart pass' AND e.end_third='mid' THEN 1 ELSE 0 END) AS smart_passes_mid,
        SUM(CASE WHEN e.subEventName_norm='smart pass' AND e.end_third='att' THEN 1 ELSE 0 END) AS smart_passes_att,

        SUM(CASE WHEN e.subEventName_norm='head pass' AND e.end_third='def' THEN 1 ELSE 0 END) AS head_passes_def,
        SUM(CASE WHEN e.subEventName_norm='head pass' AND e.end_third='mid' THEN 1 ELSE 0 END) AS head_passes_mid,
        SUM(CASE WHEN e.subEventName_norm='head pass' AND e.end_third='att' THEN 1 ELSE 0 END) AS head_passes_att,

        -- Cross-like
        SUM(CASE WHEN e.subEventName_norm IN ('cross','free kick cross') AND e.end_third='def' THEN 1 ELSE 0 END) AS crosses_def,
        SUM(CASE WHEN e.subEventName_norm IN ('cross','free kick cross') AND e.end_third='mid' THEN 1 ELSE 0 END) AS crosses_mid,
        SUM(CASE WHEN e.subEventName_norm IN ('cross','free kick cross') AND e.end_third='att' THEN 1 ELSE 0 END) AS crosses_att,

        -- Shots
        SUM(CASE WHEN e.subEventName_norm='head shot' AND e.end_third='def' THEN 1 ELSE 0 END) AS head_shots_def,
        SUM(CASE WHEN e.subEventName_norm='head shot' AND e.end_third='mid' THEN 1 ELSE 0 END) AS head_shots_mid,
        SUM(CASE WHEN e.subEventName_norm='head shot' AND e.end_third='att' THEN 1 ELSE 0 END) AS head_shots_att,

        SUM(CASE WHEN e.subEventName_norm='shot on target' AND e.end_third='def' THEN 1 ELSE 0 END) AS on_target_shots_def,
        SUM(CASE WHEN e.subEventName_norm='shot on target' AND e.end_third='mid' THEN 1 ELSE 0 END) AS on_target_shots_mid,
        SUM(CASE WHEN e.subEventName_norm='shot on target' AND e.end_third='att' THEN 1 ELSE 0 END) AS on_target_shots_att,

        SUM(CASE WHEN e.subEventName_norm='shot off target' AND e.end_third='def' THEN 1 ELSE 0 END) AS off_target_shots_def,
        SUM(CASE WHEN e.subEventName_norm='shot off target' AND e.end_third='mid' THEN 1 ELSE 0 END) AS off_target_shots_mid,
        SUM(CASE WHEN e.subEventName_norm='shot off target' AND e.end_third='att' THEN 1 ELSE 0 END) AS off_target_shots_att,

        SUM(CASE WHEN e.subEventName_norm='free kick shot' AND e.end_third='def' THEN 1 ELSE 0 END) AS free_kick_shots_def,
        SUM(CASE WHEN e.subEventName_norm='free kick shot' AND e.end_third='mid' THEN 1 ELSE 0 END) AS free_kick_shots_mid,
        SUM(CASE WHEN e.subEventName_norm='free kick shot' AND e.end_third='att' THEN 1 ELSE 0 END) AS free_kick_shots_att,

        SUM(CASE WHEN e.subEventName_norm IN ('penalty','penalty shot') AND e.end_third='att' THEN 1 ELSE 0 END) AS penalties_att,

        -- Defensive
        SUM(CASE WHEN e.subEventName_norm='clearance' AND e.end_third='def' THEN 1 ELSE 0 END) AS clearances_def,
        SUM(CASE WHEN e.subEventName_norm='clearance' AND e.end_third='mid' THEN 1 ELSE 0 END) AS clearances_mid,
        SUM(CASE WHEN e.subEventName_norm='clearance' AND e.end_third='att' THEN 1 ELSE 0 END) AS clearances_att,

        SUM(CASE WHEN e.subEventName_norm='interception' AND e.end_third='def' THEN 1 ELSE 0 END) AS interceptions_def,
        SUM(CASE WHEN e.subEventName_norm='interception' AND e.end_third='mid' THEN 1 ELSE 0 END) AS interceptions_mid,
        SUM(CASE WHEN e.subEventName_norm='interception' AND e.end_third='att' THEN 1 ELSE 0 END) AS interceptions_att,

        SUM(CASE WHEN e.subEventName_norm='tackle' AND e.end_third='def' THEN 1 ELSE 0 END) AS tackles_def,
        SUM(CASE WHEN e.subEventName_norm='tackle' AND e.end_third='mid' THEN 1 ELSE 0 END) AS tackles_mid,
        SUM(CASE WHEN e.subEventName_norm='tackle' AND e.end_third='att' THEN 1 ELSE 0 END) AS tackles_att,

        -- Restarts
        SUM(CASE WHEN e.subEventName_norm='corner'       AND e.end_third='def' THEN 1 ELSE 0 END) AS corners_def,
        SUM(CASE WHEN e.subEventName_norm='corner'       AND e.end_third='mid' THEN 1 ELSE 0 END) AS corners_mid,
        SUM(CASE WHEN e.subEventName_norm='corner'       AND e.end_third='att' THEN 1 ELSE 0 END) AS corners_att,

        SUM(CASE WHEN e.subEventName_norm IN ('throw in','throw-in') AND e.end_third='def' THEN 1 ELSE 0 END) AS throw_ins_def,
        SUM(CASE WHEN e.subEventName_norm IN ('throw in','throw-in') AND e.end_third='mid' THEN 1 ELSE 0 END) AS throw_ins_mid,
        SUM(CASE WHEN e.subEventName_norm IN ('throw in','throw-in') AND e.end_third='att' THEN 1 ELSE 0 END) AS throw_ins_att,

        SUM(CASE WHEN e.subEventName_norm='free kick cross' AND e.end_third='def' THEN 1 ELSE 0 END) AS free_kick_crosses_def,
        SUM(CASE WHEN e.subEventName_norm='free kick cross' AND e.end_third='mid' THEN 1 ELSE 0 END) AS free_kick_crosses_mid,
        SUM(CASE WHEN e.subEventName_norm='free kick cross' AND e.end_third='att' THEN 1 ELSE 0 END) AS free_kick_crosses_att,

        -- Fouls
        SUM(CASE WHEN e.subEventName_norm='hand foul' AND e.end_third='def' THEN 1 ELSE 0 END) AS hand_fouls_def,
        SUM(CASE WHEN e.subEventName_norm='hand foul' AND e.end_third='mid' THEN 1 ELSE 0 END) AS hand_fouls_mid,
        SUM(CASE WHEN e.subEventName_norm='hand foul' AND e.end_third='att' THEN 1 ELSE 0 END) AS hand_fouls_att

    FROM event_points_norm e
    GROUP BY e.matchId, e.teamId
),

-- 7) شمارش رویداد به تفکیک نیمه‌ها: '1h' = نیمه اول، غیر از آن = نیمه دوم
period_counts AS (
    SELECT
        e.matchId,
        e.teamId,
        SUM(CASE WHEN e.period_str='1h'  THEN 1 ELSE 0 END) AS period_1h_events,
        SUM(CASE WHEN e.period_str<>'1h' THEN 1 ELSE 0 END) AS period_2h_events
    FROM event_points_norm e
    GROUP BY e.matchId, e.teamId
),

-- 8) تجمیع per_match (home/away)
per_match AS (
    SELECT
        ts.matchId,
        ts.homeTeamId,
        ts.awayTeamId,

        -- assists
        COALESCE(a_home.assists,0) AS assists_home,
        COALESCE(a_away.assists,0) AS assists_away,

        -- مجموع‌های کلی
        COALESCE(sf_home.simple_passes,0) AS simple_passes_home,
        COALESCE(sf_away.simple_passes,0) AS simple_passes_away,
        COALESCE(sf_home.high_passes,0)   AS high_passes_home,
        COALESCE(sf_away.high_passes,0)   AS high_passes_away,
        COALESCE(sf_home.smart_passes,0)  AS smart_passes_home,
        COALESCE(sf_away.smart_passes,0)  AS smart_passes_away,
        COALESCE(sf_home.crosses,0)       AS crosses_home,
        COALESCE(sf_away.crosses,0)       AS crosses_away,
        COALESCE(sf_home.head_passes,0)   AS head_passes_home,
        COALESCE(sf_away.head_passes,0)   AS head_passes_away,

        COALESCE(sf_home.head_shots,0)        AS head_shots_home,
        COALESCE(sf_away.head_shots,0)        AS head_shots_away,
        COALESCE(sf_home.on_target_shots,0)   AS on_target_shots_home,
        COALESCE(sf_away.on_target_shots,0)   AS on_target_shots_away,
        COALESCE(sf_home.off_target_shots,0)  AS off_target_shots_home,
        COALESCE(sf_away.off_target_shots,0)  AS off_target_shots_away,
        COALESCE(sf_home.free_kick_shots,0)   AS free_kick_shots_home,
        COALESCE(sf_away.free_kick_shots,0)   AS free_kick_shots_away,
        COALESCE(sf_home.penalties,0)         AS penalties_home,
        COALESCE(sf_away.penalties,0)         AS penalties_away,

        COALESCE(sf_home.clearances,0)    AS clearances_home,
        COALESCE(sf_away.clearances,0)    AS clearances_away,
        COALESCE(sf_home.interceptions,0) AS interceptions_home,
        COALESCE(sf_away.interceptions,0) AS interceptions_away,
        COALESCE(sf_home.tackles,0)       AS tackles_home,
        COALESCE(sf_away.tackles,0)       AS tackles_away,

        COALESCE(sf_home.corners,0)           AS corners_home,
        COALESCE(sf_away.corners,0)           AS corners_away,
        COALESCE(sf_home.throw_ins,0)         AS throw_ins_home,
        COALESCE(sf_away.throw_ins,0)         AS throw_ins_away,
        COALESCE(sf_home.free_kick_crosses,0) AS free_kick_crosses_home,
        COALESCE(sf_away.free_kick_crosses,0) AS free_kick_crosses_away,

        COALESCE(sf_home.hand_fouls,0)        AS hand_fouls_home,
        COALESCE(sf_away.hand_fouls,0)        AS hand_fouls_away,

        -- نسخه‌های تفکیک‌شده بر اساس یک‌سوم (end_third)
        -- Passes
        COALESCE(sft_home.simple_passes_def,0) AS simple_passes_def_home,
        COALESCE(sft_home.simple_passes_mid,0) AS simple_passes_mid_home,
        COALESCE(sft_home.simple_passes_att,0) AS simple_passes_att_home,
        COALESCE(sft_away.simple_passes_def,0) AS simple_passes_def_away,
        COALESCE(sft_away.simple_passes_mid,0) AS simple_passes_mid_away,
        COALESCE(sft_away.simple_passes_att,0) AS simple_passes_att_away,

        COALESCE(sft_home.high_passes_def,0) AS high_passes_def_home,
        COALESCE(sft_home.high_passes_mid,0) AS high_passes_mid_home,
        COALESCE(sft_home.high_passes_att,0) AS high_passes_att_home,
        COALESCE(sft_away.high_passes_def,0) AS high_passes_def_away,
        COALESCE(sft_away.high_passes_mid,0) AS high_passes_mid_away,
        COALESCE(sft_away.high_passes_att,0) AS high_passes_att_away,

        COALESCE(sft_home.smart_passes_def,0) AS smart_passes_def_home,
        COALESCE(sft_home.smart_passes_mid,0) AS smart_passes_mid_home,
        COALESCE(sft_home.smart_passes_att,0) AS smart_passes_att_home,
        COALESCE(sft_away.smart_passes_def,0) AS smart_passes_def_away,
        COALESCE(sft_away.smart_passes_mid,0) AS smart_passes_mid_away,
        COALESCE(sft_away.smart_passes_att,0) AS smart_passes_att_away,

        COALESCE(sft_home.head_passes_def,0) AS head_passes_def_home,
        COALESCE(sft_home.head_passes_mid,0) AS head_passes_mid_home,
        COALESCE(sft_home.head_passes_att,0) AS head_passes_att_home,
        COALESCE(sft_away.head_passes_def,0) AS head_passes_def_away,
        COALESCE(sft_away.head_passes_mid,0) AS head_passes_mid_away,
        COALESCE(sft_away.head_passes_att,0) AS head_passes_att_away,

        -- Cross-like
        COALESCE(sft_home.crosses_def,0) AS crosses_def_home,
        COALESCE(sft_home.crosses_mid,0) AS crosses_mid_home,
        COALESCE(sft_home.crosses_att,0) AS crosses_att_home,
        COALESCE(sft_away.crosses_def,0) AS crosses_def_away,
        COALESCE(sft_away.crosses_mid,0) AS crosses_mid_away,
        COALESCE(sft_away.crosses_att,0) AS crosses_att_away,

        -- Shots
        COALESCE(sft_home.head_shots_def,0) AS head_shots_def_home,
        COALESCE(sft_home.head_shots_mid,0) AS head_shots_mid_home,
        COALESCE(sft_home.head_shots_att,0) AS head_shots_att_home,
        COALESCE(sft_away.head_shots_def,0) AS head_shots_def_away,
        COALESCE(sft_away.head_shots_mid,0) AS head_shots_mid_away,
        COALESCE(sft_away.head_shots_att,0) AS head_shots_att_away,

        COALESCE(sft_home.on_target_shots_def,0) AS on_target_shots_def_home,
        COALESCE(sft_home.on_target_shots_mid,0) AS on_target_shots_mid_home,
        COALESCE(sft_home.on_target_shots_att,0) AS on_target_shots_att_home,
        COALESCE(sft_away.on_target_shots_def,0) AS on_target_shots_def_away,
        COALESCE(sft_away.on_target_shots_mid,0) AS on_target_shots_mid_away,
        COALESCE(sft_away.on_target_shots_att,0) AS on_target_shots_att_away,

        COALESCE(sft_home.off_target_shots_def,0) AS off_target_shots_def_home,
        COALESCE(sft_home.off_target_shots_mid,0) AS off_target_shots_mid_home,
        COALESCE(sft_home.off_target_shots_att,0) AS off_target_shots_att_home,
        COALESCE(sft_away.off_target_shots_def,0) AS off_target_shots_def_away,
        COALESCE(sft_away.off_target_shots_mid,0) AS off_target_shots_mid_away,
        COALESCE(sft_away.off_target_shots_att,0) AS off_target_shots_att_away,

        COALESCE(sft_home.free_kick_shots_def,0) AS free_kick_shots_def_home,
        COALESCE(sft_home.free_kick_shots_mid,0) AS free_kick_shots_mid_home,
        COALESCE(sft_home.free_kick_shots_att,0) AS free_kick_shots_att_home,
        COALESCE(sft_away.free_kick_shots_def,0) AS free_kick_shots_def_away,
        COALESCE(sft_away.free_kick_shots_mid,0) AS free_kick_shots_mid_away,
        COALESCE(sft_away.free_kick_shots_att,0) AS free_kick_shots_att_away,

        COALESCE(sft_home.penalties_att,0) AS penalties_att_home,
        COALESCE(sft_away.penalties_att,0) AS penalties_att_away,

        -- Defensive
        COALESCE(sft_home.clearances_def,0) AS clearances_def_home,
        COALESCE(sft_home.clearances_mid,0) AS clearances_mid_home,
        COALESCE(sft_home.clearances_att,0) AS clearances_att_home,
        COALESCE(sft_away.clearances_def,0) AS clearances_def_away,
        COALESCE(sft_away.clearances_mid,0) AS clearances_mid_away,
        COALESCE(sft_away.clearances_att,0) AS clearances_att_away,

        COALESCE(sft_home.interceptions_def,0) AS interceptions_def_home,
        COALESCE(sft_home.interceptions_mid,0) AS interceptions_mid_home,
        COALESCE(sft_home.interceptions_att,0) AS interceptions_att_home,
        COALESCE(sft_away.interceptions_def,0) AS interceptions_def_away,
        COALESCE(sft_away.interceptions_mid,0) AS interceptions_mid_away,
        COALESCE(sft_away.interceptions_att,0) AS interceptions_att_away,

        COALESCE(sft_home.tackles_def,0) AS tackles_def_home,
        COALESCE(sft_home.tackles_mid,0) AS tackles_mid_home,
        COALESCE(sft_home.tackles_att,0) AS tackles_att_home,
        COALESCE(sft_away.tackles_def,0) AS tackles_def_away,
        COALESCE(sft_away.tackles_mid,0) AS tackles_mid_away,
        COALESCE(sft_away.tackles_att,0) AS tackles_att_away,

        -- Restarts
        COALESCE(sft_home.corners_def,0)    AS corners_def_home,
        COALESCE(sft_home.corners_mid,0)    AS corners_mid_home,
        COALESCE(sft_home.corners_att,0)    AS corners_att_home,
        COALESCE(sft_away.corners_def,0)    AS corners_def_away,
        COALESCE(sft_away.corners_mid,0)    AS corners_mid_away,
        COALESCE(sft_away.corners_att,0)    AS corners_att_away,

        COALESCE(sft_home.throw_ins_def,0)  AS throw_ins_def_home,
        COALESCE(sft_home.throw_ins_mid,0)  AS throw_ins_mid_home,
        COALESCE(sft_home.throw_ins_att,0)  AS throw_ins_att_home,
        COALESCE(sft_away.throw_ins_def,0)  AS throw_ins_def_away,
        COALESCE(sft_away.throw_ins_mid,0)  AS throw_ins_mid_away,
        COALESCE(sft_away.throw_ins_att,0)  AS throw_ins_att_away,

        COALESCE(sft_home.free_kick_crosses_def,0) AS free_kick_crosses_def_home,
        COALESCE(sft_home.free_kick_crosses_mid,0) AS free_kick_crosses_mid_home,
        COALESCE(sft_home.free_kick_crosses_att,0) AS free_kick_crosses_att_home,
        COALESCE(sft_away.free_kick_crosses_def,0) AS free_kick_crosses_def_away,
        COALESCE(sft_away.free_kick_crosses_mid,0) AS free_kick_crosses_mid_away,
        COALESCE(sft_away.free_kick_crosses_att,0) AS free_kick_crosses_att_away,

        COALESCE(sft_home.hand_fouls_def,0) AS hand_fouls_def_home,
        COALESCE(sft_home.hand_fouls_mid,0) AS hand_fouls_mid_home,
        COALESCE(sft_home.hand_fouls_att,0) AS hand_fouls_att_home,
        COALESCE(sft_away.hand_fouls_def,0) AS hand_fouls_def_away,
        COALESCE(sft_away.hand_fouls_mid,0) AS hand_fouls_mid_away,
        COALESCE(sft_away.hand_fouls_att,0) AS hand_fouls_att_away,

        -- رویداد به تفکیک نیمه
        COALESCE(pc_home.period_1h_events,0) AS period_1h_events_home,
        COALESCE(pc_home.period_2h_events,0) AS period_2h_events_home,
        COALESCE(pc_away.period_1h_events,0) AS period_1h_events_away,
        COALESCE(pc_away.period_2h_events,0) AS period_2h_events_away,

        ts.homeGoals, ts.awayGoals
    FROM team_sides ts
    LEFT JOIN assists_by_team a_home
        ON a_home.matchId=ts.matchId AND a_home.teamId=ts.homeTeamId
    LEFT JOIN assists_by_team a_away
        ON a_away.matchId=ts.matchId AND a_away.teamId=ts.awayTeamId
    LEFT JOIN sub_features sf_home
        ON sf_home.matchId=ts.matchId AND sf_home.teamId=ts.homeTeamId
    LEFT JOIN sub_features sf_away
        ON sf_away.matchId=ts.matchId AND sf_away.teamId=ts.awayTeamId
    LEFT JOIN sub_features_thirds sft_home
        ON sft_home.matchId=ts.matchId AND sft_home.teamId=ts.homeTeamId
    LEFT JOIN sub_features_thirds sft_away
        ON sft_away.matchId=ts.matchId AND sft_away.teamId=ts.awayTeamId
    LEFT JOIN period_counts pc_home
        ON pc_home.matchId=ts.matchId AND pc_home.teamId=ts.homeTeamId
    LEFT JOIN period_counts pc_away
        ON pc_away.matchId=ts.matchId AND pc_away.teamId=ts.awayTeamId
)

-- 9) خروجی نهایی + برچسب نتیجه و تفاضل‌ها
SELECT
  p.matchId, p.homeTeamId, p.awayTeamId,
  CASE
    WHEN p.homeGoals > p.awayGoals THEN 'home_win'
    WHEN p.homeGoals < p.awayGoals THEN 'away_win'
    ELSE 'draw'
  END AS result,

  -- Assist + diff
  p.assists_home, p.assists_away, (p.assists_home - p.assists_away) AS assists_diff,

  -- (نمونه‌ای از تفاضل‌ها؛ در صورت نیاز می‌توانی برای همهٔ فیچرها هم diff بسازی)
  -- پاس‌ها
  p.simple_passes_home, p.simple_passes_away, (p.simple_passes_home - p.simple_passes_away) AS simple_passes_diff,
  p.high_passes_home,   p.high_passes_away,   (p.high_passes_home   - p.high_passes_away)   AS high_passes_diff,
  p.smart_passes_home,  p.smart_passes_away,  (p.smart_passes_home  - p.smart_passes_away)  AS smart_passes_diff,
  p.crosses_home,       p.crosses_away,       (p.crosses_home       - p.crosses_away)       AS crosses_diff,
  p.head_passes_home,   p.head_passes_away,   (p.head_passes_home   - p.head_passes_away)   AS head_passes_diff,

  -- شوت‌ها
  p.head_shots_home,        p.head_shots_away,        (p.head_shots_home        - p.head_shots_away)        AS head_shots_diff,
  p.on_target_shots_home,   p.on_target_shots_away,   (p.on_target_shots_home   - p.on_target_shots_away)   AS on_target_shots_diff,
  p.off_target_shots_home,  p.off_target_shots_away,  (p.off_target_shots_home  - p.off_target_shots_away)  AS off_target_shots_diff,
  p.free_kick_shots_home,   p.free_kick_shots_away,   (p.free_kick_shots_home   - p.free_kick_shots_away)   AS free_kick_shots_diff,
  p.penalties_home,         p.penalties_away,         (p.penalties_home         - p.penalties_away)         AS penalties_diff,

  -- دفاعی
  p.clearances_home, p.clearances_away, (p.clearances_home - p.clearances_away) AS clearances_diff,
  p.interceptions_home, p.interceptions_away, (p.interceptions_home - p.interceptions_away) AS interceptions_diff,
  p.tackles_home, p.tackles_away, (p.tackles_home - p.tackles_away) AS tackles_diff,

  -- ری‌استارت‌ها
  p.corners_home, p.corners_away, (p.corners_home - p.corners_away) AS corners_diff,
  p.throw_ins_home, p.throw_ins_away, (p.throw_ins_home - p.throw_ins_away) AS throw_ins_diff,
  p.free_kick_crosses_home, p.free_kick_crosses_away, (p.free_kick_crosses_home - p.free_kick_crosses_away) AS free_kick_crosses_diff,

  -- خطا
  p.hand_fouls_home, p.hand_fouls_away, (p.hand_fouls_home - p.hand_fouls_away) AS hand_fouls_diff,

  -- نسخه‌های end_third (home/away) — در صورت نیاز می‌توان برای همه diff هم اضافه کرد
  -- نمونه: simple passes by thirds
  p.simple_passes_def_home, p.simple_passes_def_away,
  p.simple_passes_mid_home, p.simple_passes_mid_away,
  p.simple_passes_att_home, p.simple_passes_att_away,

  -- شمارش رویداد به تفکیک نیمه
  p.period_1h_events_home, p.period_2h_events_home,
  p.period_1h_events_away, p.period_2h_events_away,

  -- گل‌ها
  p.homeGoals, p.awayGoals

FROM per_match p
ORDER BY p.matchId;