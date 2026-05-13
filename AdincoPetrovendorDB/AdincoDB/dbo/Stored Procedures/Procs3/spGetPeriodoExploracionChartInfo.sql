CREATE PROCEdURE spGetPeriodoExploracionChartInfo
	@pIdUsuario		int,
	@pIdContrato	int
AS
BEGIN
SET NOCOUNT ON
	create table #tmp
	(
		Id			int,
		Titulo		varchar(50),
		Valor		decimal(4,2),
		Serie		int
	)

	insert into	#tmp
	SELECT
		1,
		'Foreign',
		CASE WHEN @pIdContrato = 10049	THEN 87 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 85 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 87	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 85	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 97	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1
UNION
	SELECT
		2,
		'National Content',
		CASE WHEN @pIdContrato = 10049	THEN 13 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1

	select	id,
			Titulo,
			Valor,
			Serie
	from	#tmp
END