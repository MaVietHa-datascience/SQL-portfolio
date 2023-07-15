--1. Đếm số lượng olympic games đã được tổ chức

select count(distinct games) as so_ky_olympic 
from athlete_event

-- 2. Tên của các kỳ olympic

select distinct games as cac_ky_olympic 
from athlete_event 
order by cac_ky_olympic
 
-- 3. số lượng các quốc gia tham gia vào từng kỳ olympic

select  games, count(distinct noc) as so_luong_quoc_gia_tham_du 
from athlete_event 
group by games
 
-- 4. năm có số lượng quốc gia tham dự olympic ít nhất và nhiều nhất

with t1 as
          (select games, nr.region
           from athlete_event ath
           join noc_regions nr ON nr.noc=ath.noc
           group by games, nr.region),
      t2 as
          (select games, count(1) as tong_so_quoc_gia
           from t1
           group by games)
select distinct
concat(first_value(games) over(order by tong_so_quoc_gia), ' - ', first_value(tong_so_quoc_gia) over(order by tong_so_quoc_gia)) as Lowest_Countries,
concat(first_value(games) over(order by tong_so_quoc_gia desc), ' - ', first_value(tong_so_quoc_gia) over(order by tong_so_quoc_gia desc)) as Highest_Countries
from t2
order by 1;

-- 5. quốc gia tham gia vào tất cả các kỳ olympic

with t1 as
			(select distinct games as cac_ky_olympic, 
			noc from athlete_event),
	 t2 as
			(select distinct noc, 
			count(cac_ky_olympic) over(partition by noc) as so_ky_olympic_tham_gia from t1)
select * from t2 
where so_ky_olympic_tham_gia = (select  count(distinct games) as so_ky_olympic from athlete_event)
 
 -- 6. Môn thể thao có tại tất cả các thế vận hội mùa hè
with t1 as
			(select distinct games as cac_ky_olympic_mua_he, 
			sport from athlete_event where season = 'Summer'),
	 t2 as
			(select distinct sport, 
			count(cac_ky_olympic_mua_he) over(partition by sport) as so_ky_olympic_mua_he_tham_gia from t1)
select * from t2 
where so_ky_olympic_mua_he_tham_gia = (select  count(distinct games) as so_ky_olympic from athlete_event where season = 'Summer')
 
 -- 7. môn thể thao chỉ được chơi 1 lần.

with t1 as
			(select distinct games as cac_ky_olympic_mua_he, sport from athlete_event where season = 'Summer'),
	 t2 as
			(select distinct sport, count(cac_ky_olympic_mua_he) over(partition by sport) as so_ky_olympic_mua_he_tham_gia from t1)
select * from t2 where so_ky_olympic_mua_he_tham_gia = 1

-- 8. Tỷ lệ nam / nữ tham gia vào tất cả các kỳ thế vận hội
 
 with t1 as 
			(select games, count(distinct ID) as tong_so_nam from athlete_event where sex = 'M' group by games),
	  t2 as 
			(select games, count(distinct ID) as tong_so_nu from athlete_event where sex = 'F' group by games)
select t1.games, tong_so_nam, tong_so_nu, 
		round(cast(tong_so_nam as decimal(4,0))/cast(tong_so_nu as decimal(4,0)),2,2) as ty_le 
		from t1 join t2 on t1.games = t2.games

 -- 9 Các vận động viên dành được Top 5 số lượng huy chương

with t1 as
           (select name, team, count(1) as so_huy_chuong_vang
            from athlete_event
            where medal = 'Gold'
            group by name, team
           ),
     t2 as
           (select *, dense_rank() over (order by so_huy_chuong_vang desc) as xep_hang
            from t1)
select name, team, so_huy_chuong_vang
from t2
where xep_hang <= 5;
	
	-- 10. Môn thể thao ấn độ dành được nhiều huy chương nhất

select top 1 sport, count(medal) as so_huy_chuong 
from athlete_event join noc_regions on
athlete_event.noc = noc_regions.noc 
where medal <> 'NA' and region = 'India' 
group by sport order by so_huy_chuong desc

 -- 11. Các kỳ olympic trong đó Ấn độ dành huy chương trong bộ môn hockey

select team, sport, games, count(1) as tong_so_huy_chuong
from athlete_event
where medal <> 'NA'
and team = 'India' and sport = 'Hockey'
group by team, sport, games
order by tong_so_huy_chuong desc;