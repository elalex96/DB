IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerControlFinanciero'
    )
    DROP PROCEDURE p_OT_ObtenerControlFinanciero
GO
CREATE PROC [dbo].[p_OT_ObtenerControlFinanciero]
@pIdOTSolicitud int
as

	DECLARE @noEstimaciones int,
		@e1 varchar(20),@e2 varchar(20),@e3 varchar(20),@e4 varchar(20),@e5 varchar(20),@e6 varchar(20),@e7 varchar(20),@e8 varchar(20),@e9 varchar(20),@e10 varchar(20),
		@e11 varchar(20),@e12 varchar(20),@e13 varchar(20),@e14 varchar(20),@e15 varchar(20),@e16 varchar(20),@e17 varchar(20),@e18 varchar(20),@e19 varchar(20),@e20 varchar(20),

		@c1 varchar(20),@c2 varchar(20),@c3 varchar(20),@c4 varchar(20),@c5 varchar(20),@c6 varchar(20),@c7 varchar(20),@c8 varchar(20),@c9 varchar(20),@c10 varchar(20),
		@c11 varchar(20),@c12 varchar(20),@c13 varchar(20),@c14 varchar(20),@c15 varchar(20),@c16 varchar(20),@c17 varchar(20),@c18 varchar(20),@c19 varchar(20),@c20 varchar(20),

		@i int,@folioAux varchar(50),@consecutivoAux int,
		@importeOT decimal(15,5)
	

	select 		
		IdOTEstimacion = est.IdOTEstimacion,
		est.FolioEstimacion,
		Concepto = scm.Concepto,
		DescripcionMat = scm.Descripcion,
		Unidad = u.Unidad,
		CantidadOT = CAST(scm.Cantidad AS decimal(15,5)),	
		CantidadEstimacion = CAST(isnull(est.Cantidad,0) AS  decimal(15,5)),
		PrecioUnitario = CAST(scm.PrecioUnitario AS decimal(15,5)),
		Consecutivo = isnull(est.Consecutivo,0),
		TotalEstimacion = CAST(isnull(est.Cantidad,0) * est.PrecioUnitario AS decimal(15,5)),
		TotalOT = (SELECT SUM(Cantidad*PrecioUnitario)  FROM SC_Materiales ST1 WHERE ST1.IdSCMaterial = otm.IdSCMaterial	)
	into #tmpEstimaciones		
	from OT_Solicitud ot
	inner join OT_SolicitudMaterial otm on otm.idOTSolicitud = ot.IdOTSolicitud
	inner join SC_Materiales scm on scm.IdSCMaterial = otm.IdSCMaterial	
	inner join Petrovendor.dbo.[PV_MM_MaterialUnidad] u on u.IdUnidad = scm.IdUnidad	
	left join vwOTEstimacion est on est.IdOTSolicitud = ot.IdOTSolicitud and
									est.IdSCMaterial = otm.IdSCMaterial
	where ot.IdOTSolicitud = @pIdOTSolicitud

	select @noEstimaciones = count(distinct IdOTEstimacion),
		@i = 1
	from #tmpEstimaciones	

	

	select FolioEstimacion,
		i = identity(int,1,1),
		consecutivo = max(consecutivo)
	into #tmpI
	from #tmpEstimaciones
	where FolioEstimacion is not null
	group by FolioEstimacion
	

	while @i <= 20
	begin

		select @folioAux= FolioEstimacion,
			@consecutivoAux = consecutivo
		from #tmpI
		where i= @i

		if @i = 1 set @e1 = @folioAux if @i = 2 set @e2 = @folioAux if @i = 3 set @e3= @folioAux if @i = 4 set @e4 = @folioAux
		if @i = 5 set @e5 = @folioAux if @i = 6 set @e6 = @folioAux if @i = 7 set @e7= @folioAux if @i = 8 set @e8 = @folioAux
		if @i = 9 set @e9 = @folioAux if @i = 10 set @e10 = @folioAux if @i = 11 set @e11= @folioAux if @i = 12 set @e12 = @folioAux
		if @i = 13 set @e13 = @folioAux if @i = 14 set @e14 = @folioAux if @i = 15 set @e15= @folioAux if @i = 16 set @e16 = @folioAux
		if @i = 17 set @e17 = @folioAux if @i = 18 set @e18 = @folioAux if @i = 19 set @e19= @folioAux if @i = 20 set @e20 = @folioAux

		if @i = 1 set @c1 = @consecutivoAux if @i = 2 set @c2 = @consecutivoAux if @i = 3 set @c3= @consecutivoAux if @i = 4 set @c4 = @consecutivoAux
		if @i = 5 set @c5 = @consecutivoAux if @i = 6 set @c6 = @consecutivoAux if @i = 7 set @c7= @consecutivoAux if @i = 8 set @c8 = @consecutivoAux
		if @i = 9 set @c9 = @consecutivoAux if @i = 10 set @c10 = @consecutivoAux if @i = 11 set @c11= @consecutivoAux if @i = 12 set @c12 = @consecutivoAux
		if @i = 13 set @c13 = @consecutivoAux if @i = 14 set @c14 = @consecutivoAux if @i = 15 set @c15= @consecutivoAux if @i = 16 set @c16 = @consecutivoAux
		if @i = 17 set @c17 = @consecutivoAux if @i = 18 set @c18 = @consecutivoAux if @i = 19 set @c19= @consecutivoAux if @i = 20 set @c20 = @consecutivoAux
				
		
		set @i = @i +1
		set @folioAux = null

	end

	select Concepto ,
		DescripcionMat ,
		Unidad ,
		CantidadOT ,
		nEstimaciones = @noEstimaciones,
		PrecioUnitario,
		Importe = CantidadOT * PrecioUnitario,
		nE1 = isnull(@e1,''),
		cantE1 = SUM(case when FolioEstimacion = @e1 then CantidadEstimacion else 0 end),
		impE1 = cast(SUM(case when FolioEstimacion = @e1 then CantidadEstimacion else 0 end) * PrecioUnitario as decimal(15,5)),
		cantSE1 = CantidadOT - SUM(case when Consecutivo <= @c1 then CantidadEstimacion else 0 end),
		impSE1 = abs( cast((CantidadOT - SUM(case when Consecutivo <= @c1 then CantidadEstimacion else 0 end)) * PrecioUnitario as decimal(15,5))),

		nE2 = isnull(@e2,''),
		cantE2 = SUM(case when FolioEstimacion = @e2 then CantidadEstimacion else 0 end),
		impE2 = SUM(case when FolioEstimacion = @e2 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE2 = CantidadOT - SUM(case when Consecutivo <= @c2 then CantidadEstimacion else 0 end),
		impSE2 = abs((CantidadOT - SUM(case when Consecutivo <= @c2 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE3 = isnull(@e3,''),
		cantE3 = SUM(case when FolioEstimacion = @e3 then CantidadEstimacion else 0 end),
		impE3 = SUM(case when FolioEstimacion = @e3 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE3 = CantidadOT - SUM(case when Consecutivo <= @c3 then CantidadEstimacion else 0 end),
		impSE3 = abs((CantidadOT - SUM(case when Consecutivo <= @c3 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE4 = isnull(@e4,''),
		cantE4 = SUM(case when FolioEstimacion = @e4 then CantidadEstimacion else 0 end),
		impE4 = SUM(case when FolioEstimacion = @e4 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE4 = CantidadOT - SUM(case when Consecutivo <= @c4 then CantidadEstimacion else 0 end),
		impSE4 =abs( (CantidadOT - SUM(case when Consecutivo <= @c4 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE5 = isnull(@e5,''),
		cantE5 = SUM(case when FolioEstimacion = @e5 then CantidadEstimacion else 0 end),
		impE5 = SUM(case when FolioEstimacion = @e5 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE5 = CantidadOT - SUM(case when Consecutivo <= @c5 then CantidadEstimacion else 0 end),
		impSE5 = abs((CantidadOT - SUM(case when Consecutivo <= @c5 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE6 = isnull(@e6,''),
		cantE6 = SUM(case when FolioEstimacion = @e6 then CantidadEstimacion else 0 end),
		impE6 = SUM(case when FolioEstimacion = @e6 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE6 = CantidadOT - SUM(case when Consecutivo <= @c6 then CantidadEstimacion else 0 end),
		impSE6 = abs((CantidadOT - SUM(case when Consecutivo <= @c6 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE7 = isnull(@e7,''),
		cantE7 = SUM(case when FolioEstimacion = @e7 then CantidadEstimacion else 0 end),
		impE7 = SUM(case when FolioEstimacion = @e7 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE7 = CantidadOT - SUM(case when Consecutivo <= @c7 then CantidadEstimacion else 0 end),
		impSE7 = abs((CantidadOT - SUM(case when Consecutivo <= @c7 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE8 = isnull(@e8,''),
		cantE8 = SUM(case when FolioEstimacion = @e8 then CantidadEstimacion else 0 end),
		impE8 = SUM(case when FolioEstimacion = @e8 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE8 = CantidadOT - SUM(case when Consecutivo <= @c8 then CantidadEstimacion else 0 end),
		impSE8 = abs((CantidadOT - SUM(case when Consecutivo <= @c8 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE9 = isnull(@e9,''),
		cantE9 = SUM(case when FolioEstimacion = @e9 then CantidadEstimacion else 0 end),
		impE9 = SUM(case when FolioEstimacion = @e9 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE9 = CantidadOT - SUM(case when Consecutivo <= @c9 then CantidadEstimacion else 0 end),
		impSE9 = abs((CantidadOT - SUM(case when Consecutivo <= @c9 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE10 = isnull(@e10,''),
		cantE10 = SUM(case when FolioEstimacion = @e10 then CantidadEstimacion else 0 end),
		impE10 = SUM(case when FolioEstimacion = @e10 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE10 = CantidadOT - SUM(case when Consecutivo <= @c10 then CantidadEstimacion else 0 end),
		impSE10 = abs((CantidadOT - SUM(case when Consecutivo <= @c10 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE11 = isnull(@e11,''),
		cantE11 = SUM(case when FolioEstimacion = @e11 then CantidadEstimacion else 0 end),
		impE11 = SUM(case when FolioEstimacion = @e11 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE11 = CantidadOT - SUM(case when Consecutivo <= @c11 then CantidadEstimacion else 0 end),
		impSE11 = abs((CantidadOT - SUM(case when Consecutivo <= @c11 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE12 = isnull(@e12,''),
		cantE12 = SUM(case when FolioEstimacion = @e12 then CantidadEstimacion else 0 end),
		impE12 = SUM(case when FolioEstimacion = @e12 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE12 = CantidadOT - SUM(case when Consecutivo <= @c12 then CantidadEstimacion else 0 end),
		impSE12 = abs((CantidadOT - SUM(case when Consecutivo <= @c12 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE13 = isnull(@e13,''),
		cantE13 = SUM(case when FolioEstimacion = @e13 then CantidadEstimacion else 0 end),
		impE13 = SUM(case when FolioEstimacion = @e13 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE13 = CantidadOT - SUM(case when Consecutivo <= @c13 then CantidadEstimacion else 0 end),
		impSE13 = abs((CantidadOT - SUM(case when Consecutivo <= @c13 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE14 = isnull(@e14,''),
		cantE14 = SUM(case when FolioEstimacion = @e14 then CantidadEstimacion else 0 end),
		impE14 = SUM(case when FolioEstimacion = @e14 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE14 = CantidadOT - SUM(case when Consecutivo <= @c14 then CantidadEstimacion else 0 end),
		impSE14 = abs((CantidadOT - SUM(case when Consecutivo <= @c14 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE15 = isnull(@e15,''),
		cantE15 = SUM(case when FolioEstimacion = @e15 then CantidadEstimacion else 0 end),
		impE15 = SUM(case when FolioEstimacion = @e15 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE15 = CantidadOT - SUM(case when Consecutivo <= @c15 then CantidadEstimacion else 0 end),
		impSE15 = abs((CantidadOT - SUM(case when Consecutivo <= @c15 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE16 = isnull(@e16,''),
		cantE16 = SUM(case when FolioEstimacion = @e16 then CantidadEstimacion else 0 end),
		impE16 = SUM(case when FolioEstimacion = @e16 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE16 = CantidadOT - SUM(case when Consecutivo <= @c16 then CantidadEstimacion else 0 end),
		impSE16 = abs((CantidadOT - SUM(case when Consecutivo <= @c16 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE17 = isnull(@e17,''),
		cantE17 = SUM(case when FolioEstimacion = @e17 then CantidadEstimacion else 0 end),
		impE17 = SUM(case when FolioEstimacion = @e17 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE17 = CantidadOT - SUM(case when Consecutivo <= @c17 then CantidadEstimacion else 0 end),
		impSE17 = abs((CantidadOT - SUM(case when Consecutivo <= @c17 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE18 = isnull(@e18,''),
		cantE18 = SUM(case when FolioEstimacion = @e18 then CantidadEstimacion else 0 end),
		impE18 = SUM(case when FolioEstimacion = @e18 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE18 = CantidadOT - SUM(case when Consecutivo <= @c18 then CantidadEstimacion else 0 end),
		impSE18 = abs((CantidadOT - SUM(case when Consecutivo <= @c18 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE19 = isnull(@e19,''),
		cantE19 = SUM(case when FolioEstimacion = @e19 then CantidadEstimacion else 0 end),
		impE19 = SUM(case when FolioEstimacion = @e19 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE19 = CantidadOT - SUM(case when Consecutivo <= @c19 then CantidadEstimacion else 0 end),
		impSE19 = abs((CantidadOT - SUM(case when Consecutivo <= @c19 then CantidadEstimacion else 0 end)) * PrecioUnitario),

		nE20 = isnull(@e20,''),
		cantE20 = SUM(case when FolioEstimacion = @e20 then CantidadEstimacion else 0 end),
		impE20 = SUM(case when FolioEstimacion = @e20 then CantidadEstimacion else 0 end) * PrecioUnitario,
		cantSE20 = CantidadOT - SUM(case when Consecutivo <= @c20 then CantidadEstimacion else 0 end),
		impSE20 = abs((CantidadOT - SUM(case when Consecutivo <= @c20 then CantidadEstimacion else 0 end)) * PrecioUnitario)
	into #tmpControlFinancieroMat	
	from #tmpEstimaciones
	group by COncepto ,
		DescripcionMat ,
		Unidad ,
		CantidadOT ,
		PrecioUnitario

	
	
	select @importeOT = Sum(importe)
	from #tmpControlFinancieroMat

	SELECT *
	FROM (
		SELECT *,
			CAST(Concepto AS VARCHAR) AS ConceptoStr
		FROM #tmpControlFinancieroMat
	) AS T
	CROSS APPLY (
		SELECT
			CASE 
				WHEN CHARINDEX('-', T.ConceptoStr) > 0 AND 
					 ISNUMERIC(LEFT(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) - 1)) = 1
				THEN TRY_CAST(LEFT(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) - 1) AS INT)
				ELSE NULL
			END AS Parte1,
			CASE 
				WHEN CHARINDEX('-', T.ConceptoStr) > 0 AND 
					 ISNUMERIC(SUBSTRING(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) + 1, LEN(T.ConceptoStr))) = 1
				THEN TRY_CAST(SUBSTRING(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) + 1, LEN(T.ConceptoStr)) AS INT)
				ELSE NULL
			END AS Parte2
	) AS X
	ORDER BY Parte1, Parte2



	Create Table #tmpAcumulados
	(
		impE1 decimal(15,5),
		impSE1 decimal(15,5),
		afMenE1 decimal(15,5),
		afMenSE1 decimal(15,5),
		afAcumE1 decimal(15,5),
		--
		impE2 decimal(15,5) null,impSE2 decimal(15,5) null,afMenE2 decimal(15,5) null,	afMenSE2 decimal(15,5) null,afAcumE2 decimal(15,5) null,
		impE3 decimal(15,5) null,impSE3 decimal(15,5) null,afMenE3 decimal(15,5) null,	afMenSE3 decimal(15,5) null,afAcumE3 decimal(15,5) null,
		impE4 decimal(15,5) null,impSE4 decimal(15,5) null,afMenE4 decimal(15,5) null,	afMenSE4 decimal(15,5) null,afAcumE4 decimal(15,5) null,
		impE5 decimal(15,5) null,impSE5 decimal(15,5) null,afMenE5 decimal(15,5) null,	afMenSE5 decimal(15,5) null,afAcumE5 decimal(15,5) null,
		impE6 decimal(15,5) null,impSE6 decimal(15,5) null,afMenE6 decimal(15,5) null,	afMenSE6 decimal(15,5) null,afAcumE6 decimal(15,5) null,
		impE7 decimal(15,5) null,impSE7 decimal(15,5) null,afMenE7 decimal(15,5) null,	afMenSE7 decimal(15,5) null,afAcumE7 decimal(15,5) null,

		impE8 decimal(15,5) null,impSE8 decimal(15,5) null,afMenE8 decimal(15,5) null,	afMenSE8 decimal(15,5) null,afAcumE8 decimal(15,5) null,
		impE9 decimal(15,5) null,impSE9 decimal(15,5) null,afMenE9 decimal(15,5) null,	afMenSE9 decimal(15,5) null,afAcumE9 decimal(15,5) null,
		impE10 decimal(15,5) null,impSE10 decimal(15,5) null,afMenE10 decimal(15,5) null,	afMenSE10 decimal(15,5) null,afAcumE10 decimal(15,5) null,
		impE11 decimal(15,5) null,impSE11 decimal(15,5) null,afMenE11 decimal(15,5) null,	afMenSE11 decimal(15,5) null,afAcumE11 decimal(15,5) null,
		impE12 decimal(15,5) null,impSE12 decimal(15,5) null,afMenE12 decimal(15,5) null,	afMenSE12 decimal(15,5) null,afAcumE12 decimal(15,5) null,
		impE13 decimal(15,5) null,impSE13 decimal(15,5) null,afMenE13 decimal(15,5) null,	afMenSE13 decimal(15,5) null,afAcumE13 decimal(15,5) null,
		impE14 decimal(15,5) null,impSE14 decimal(15,5) null,afMenE14 decimal(15,5) null,	afMenSE14 decimal(15,5) null,afAcumE14 decimal(15,5) null,
		impE15 decimal(15,5) null,impSE15 decimal(15,5) null,afMenE15 decimal(15,5) null,	afMenSE15 decimal(15,5) null,afAcumE15 decimal(15,5) null,
		impE16 decimal(15,5) null,impSE16 decimal(15,5) null,afMenE16 decimal(15,5) null,	afMenSE16 decimal(15,5) null,afAcumE16 decimal(15,5) null,
		impE17 decimal(15,5) null,impSE17 decimal(15,5) null,afMenE17 decimal(15,5) null,	afMenSE17 decimal(15,5) null,afAcumE17 decimal(15,5) null,
		impE18 decimal(15,5) null,impSE18 decimal(15,5) null,afMenE18 decimal(15,5) null,	afMenSE18 decimal(15,5) null,afAcumE18 decimal(15,5) null,
		impE19 decimal(15,5) null,impSE19 decimal(15,5) null,afMenE19 decimal(15,5) null,	afMenSE19 decimal(15,5) null,afAcumE19 decimal(15,5) null,
		impE20 decimal(15,5) null,impSE20 decimal(15,5) null,afMenE20 decimal(15,5) null,	afMenSE20 decimal(15,5) null,afAcumE20 decimal(15,5) null
		

		
		
	)
	insert into #tmpAcumulados(impE1,impSE1,afMenE1,afMenSE1,afAcumE1)
	select null,null,null,null,null

	/*************EST1**************************/
	update #tmpAcumulados
	set impE1 =(select SUM(t1.impE1) from #tmpControlFinancieroMat t1),
			impSE1 = (select SUM(t1.impSE1) from #tmpControlFinancieroMat t1) ,
			afMenE1 = (select SUM(t1.impE1) / @importeOT from #tmpControlFinancieroMat t1) *100 ,
			afMenSE1 =(select  SUM(t1.impSE1)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE1 =  (select SUM(t1.impE1) / @importeOT from #tmpControlFinancieroMat t1)  *100
	from #tmpAcumulados t1

	/*****************EST2**************************/
	update #tmpAcumulados
	set impE2 =(select SUM(t1.impE2) from #tmpControlFinancieroMat t1),impSE2 = (select SUM(t1.impSE2) from #tmpControlFinancieroMat t1) ,
			afMenE2 = (select SUM(t1.impE2) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE2 =(select  SUM(t1.impSE2)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE2 = ( (select  SUM(t1.impE2)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE1) 
	from #tmpAcumulados t1

	/*************EST3**************************/
	update #tmpAcumulados
	set impE3 =(select SUM(t1.impE3) from #tmpControlFinancieroMat t1),impSE3 = (select SUM(t1.impSE3) from #tmpControlFinancieroMat t1) ,
			afMenE3 = (select SUM(t1.impE3) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE3 =(select  SUM(t1.impSE3)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE3 = ( (select  SUM(t1.impE3)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE2) 
	from #tmpAcumulados t1

	/*************EST4**************************/
	update #tmpAcumulados
	set impE4 =(select SUM(t1.impE4) from #tmpControlFinancieroMat t1),impSE4 = (select SUM(t1.impSE4) from #tmpControlFinancieroMat t1) ,
			afMenE4 = (select SUM(t1.impE4) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE4 =(select  SUM(t1.impSE4)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE4 = ( (select  SUM(t1.impE4)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE3) 
	from #tmpAcumulados t1

	/*************EST5**************************/
	update #tmpAcumulados
	set impE5 =(select SUM(t1.impE5) from #tmpControlFinancieroMat t1),impSE5 = (select SUM(t1.impSE5) from #tmpControlFinancieroMat t1) ,
			afMenE5 = (select SUM(t1.impE5) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE5 =(select  SUM(t1.impSE5)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE5 = ( (select  SUM(t1.impE5)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE4) 
	from #tmpAcumulados t1
	
	/*************EST6**************************/
	update #tmpAcumulados
	set impE6 =(select SUM(t1.impE6) from #tmpControlFinancieroMat t1),impSE6 = (select SUM(t1.impSE6) from #tmpControlFinancieroMat t1) ,
			afMenE6 = (select SUM(t1.impE6) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE6 =(select  SUM(t1.impSE6)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE6 = ( (select  SUM(t1.impE6)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE5) 
	from #tmpAcumulados t1	

	/*************EST7**************************/
	update #tmpAcumulados
	set impE7 =(select SUM(t1.impE7) from #tmpControlFinancieroMat t1),impSE7 = (select SUM(t1.impSE7) from #tmpControlFinancieroMat t1) ,
			afMenE7 = (select SUM(t1.impE7) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE7 =(select  SUM(t1.impSE7)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE7 = ( (select  SUM(t1.impE7)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE6) 
	from #tmpAcumulados t1	

	/*************EST8**************************/
	update #tmpAcumulados
	set impE8 =(select SUM(t1.impE8) from #tmpControlFinancieroMat t1),impSE8 = (select SUM(t1.impSE8) from #tmpControlFinancieroMat t1) ,
			afMenE8 = (select SUM(t1.impE8) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE8 =(select  SUM(t1.impSE8)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE8 = ( (select  SUM(t1.impE8)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE7) 
	from #tmpAcumulados t1	

	/*************EST9**************************/
	update #tmpAcumulados
	set impE9 =(select SUM(t1.impE9) from #tmpControlFinancieroMat t1),impSE9 = (select SUM(t1.impSE9) from #tmpControlFinancieroMat t1) ,
			afMenE9 = (select SUM(t1.impE9) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE9 =(select  SUM(t1.impSE9)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE9 = ( (select  SUM(t1.impE9)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE8) 
	from #tmpAcumulados t1	

	/*************EST10**************************/
	update #tmpAcumulados
	set impE10 =(select SUM(t1.impE10) from #tmpControlFinancieroMat t1),impSE10 = (select SUM(t1.impSE10) from #tmpControlFinancieroMat t1) ,
			afMenE10 = (select SUM(t1.impE10) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE10 =(select  SUM(t1.impSE10)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE10 = ( (select  SUM(t1.impE10)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE9) 
	from #tmpAcumulados t1	

	/*************EST11**************************/
	update #tmpAcumulados
	set impE11 =(select SUM(t1.impE11) from #tmpControlFinancieroMat t1),impSE11 = (select SUM(t1.impSE11) from #tmpControlFinancieroMat t1) ,
			afMenE11 = (select SUM(t1.impE11) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE11 =(select  SUM(t1.impSE11)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE11 = ( (select  SUM(t1.impE11)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE10) 
	from #tmpAcumulados t1	

	/*************EST12**************************/
	update #tmpAcumulados
	set impE12 =(select SUM(t1.impE12) from #tmpControlFinancieroMat t1),impSE12 = (select SUM(t1.impSE12) from #tmpControlFinancieroMat t1) ,
			afMenE12 = (select SUM(t1.impE12) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE12 =(select  SUM(t1.impSE12)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE12 = ( (select  SUM(t1.impE12)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE11) 
	from #tmpAcumulados t1	

	/*************EST13**************************/
	update #tmpAcumulados
	set impE13 =(select SUM(t1.impE13) from #tmpControlFinancieroMat t1),impSE13 = (select SUM(t1.impSE13) from #tmpControlFinancieroMat t1) ,
			afMenE13 = (select SUM(t1.impE13) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE13 =(select  SUM(t1.impSE13)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE13 = ( (select  SUM(t1.impE13)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE12) 
	from #tmpAcumulados t1	

	/*************EST14**************************/
	update #tmpAcumulados
	set impE14 =(select SUM(t1.impE14) from #tmpControlFinancieroMat t1),impSE14 = (select SUM(t1.impSE14) from #tmpControlFinancieroMat t1) ,
			afMenE14 = (select SUM(t1.impE14) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE14 =(select  SUM(t1.impSE14)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE14 = ( (select  SUM(t1.impE14)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE13) 
	from #tmpAcumulados t1	

	/*************EST15**************************/
	update #tmpAcumulados
	set impE15 =(select SUM(t1.impE15) from #tmpControlFinancieroMat t1),impSE15 = (select SUM(t1.impSE15) from #tmpControlFinancieroMat t1) ,
			afMenE15 = (select SUM(t1.impE15) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE15 =(select  SUM(t1.impSE15)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE15 = ( (select  SUM(t1.impE15)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE14) 
	from #tmpAcumulados t1	

	/*************EST16**************************/
	update #tmpAcumulados
	set impE16 =(select SUM(t1.impE16) from #tmpControlFinancieroMat t1),impSE16 = (select SUM(t1.impSE16) from #tmpControlFinancieroMat t1) ,
			afMenE16 = (select SUM(t1.impE16) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE16 =(select  SUM(t1.impSE16)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE16 = ( (select  SUM(t1.impE16)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE15) 
	from #tmpAcumulados t1	

	/*************EST17**************************/
	update #tmpAcumulados
	set impE17 =(select SUM(t1.impE17) from #tmpControlFinancieroMat t1),impSE17 = (select SUM(t1.impSE17) from #tmpControlFinancieroMat t1) ,
			afMenE17 = (select SUM(t1.impE17) / @importeOT from #tmpControlFinancieroMat t1) *100  ,afMenSE17 =(select  SUM(t1.impSE17)/ @importeOT from #tmpControlFinancieroMat t1) *100,
			afAcumE17 = ( (select  SUM(t1.impE17)/ @importeOT from #tmpControlFinancieroMat t1) *100 + afAcumE16) 
	from #tmpAcumulados t1	

	select * from #tmpAcumulados