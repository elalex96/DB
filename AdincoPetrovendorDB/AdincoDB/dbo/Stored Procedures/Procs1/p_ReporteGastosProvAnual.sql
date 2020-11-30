CREATE PROC p_ReporteGastosProvAnual
@pIdContrato int,
@pAnio int
AS

CREATE TABLE #Facturas
(
	IdActividadPetrolera	INT,
	IdSubactividadPetrolera	INT,
	IdTareaPetrolera	INT,
	IdSubactividad		INT,
	DescripcionActividadPetrolera	VARCHAR(500),
	SubactividadPetrolera	VARCHAR(500),
	TareaPetrolera		VARCHAR(500),
	SubTareaPetrolera	VARCHAR(5000),
	IdFactura				INT
)

	INSERT INTO #Facturas
	(
	    --IdLineaPresupuestoMes,
		IdActividadPetrolera,
		IdSubactividadPetrolera,
		IdTareaPetrolera,
		IdSubactividad,
		DescripcionActividadPetrolera,
		SubactividadPetrolera,
		TareaPetrolera,
		SubTareaPetrolera,
	    IdFactura
	)
	SELECT
		pam.IdActividadPetrolera,
		pam.IdSubactividadPetrolera,
		pam.IdTareaPetrolera,
		pam.IdSubactividad,
		DescripcionActividadPetrolera = UPPER(ap.DescripcionActividadPetrolera),
		SubactividadPetrolera = upper(sap.SubactividadPetrolera),
		TareaPetrolera = upper(tp.TareaPetrolera),
		SubTareaPetrolera = upper(isnull(s.NombreServicio,'')),
		REG.IdFactura
	from CO_Contrato c
	inner join CO_PeriodoContrato pc on pc.idContrato = c.idContrato
	inner join [dbo].[CO_AnioContractual] anioC on anioC.IdContrato =  pc.idContrato
	--inner join CO_AnioContractual ac on ac.IdContrato = pc.idContrato
	inner join CO_Presupuesto pre on pre.IdAnioContractual = anioC.IdAnioContractual
	INNER JOIN CO_LineaPresupuestoMes pam on pam.IdPresupuesto = pre.IdPresupuesto
	--inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
	inner join CO_ActividadPetroleraCNH ap on ap.IdActividadPetrolera = pam.IdActividadPetrolera
	inner join CO_SubactividadPetrolera sap on sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
	inner join dbo.CO_TareaPetrolera tp on tp.IdTareaPetrolera = pam.IdTareaPetrolera
	left join [dbo].CO_Servicio s on s.IdServicio = pam.IdSubactividad 
	inner join CO_Registro reg on reg.IdPrograma = pam.IdLineaPresupuestoMes
	JOIN dbo.FI_TransferFactura	TR
		ON	reg.IdFactura	=	TR.IdFactura
	JOIN dbo.FI_Transfer	T
			ON	TR.IdTransfer	=	T.IdTransferencia
	WHERE
		C.IdContrato = @pidContrato
		AND
		DATEPART(YEAR,T.FechaPago) = @pAnio
	GROUP BY
		pam.IdActividadPetrolera,
		pam.IdSubactividadPetrolera,
		pam.IdTareaPetrolera,
		pam.IdSubactividad,
		UPPER(ap.DescripcionActividadPetrolera),
		upper(sap.SubactividadPetrolera),
		upper(tp.TareaPetrolera),
		upper(isnull(s.NombreServicio,'')),
		REG.IdFactura

	select 
--		pam.IdLineaProgramaActividadMes,
		--pam.IdProgramaActividad,
		--pam.IdActividadPetrolera,
		--pam.IdSubactividadPetrolera,
		--pam.IdTareaPetrolera,
		--pam.IdSubactividad,
		REG.IdActividadPetrolera,
		REG.IdSubactividadPetrolera,
		REG.IdTareaPetrolera,
		REG.IdSubactividad,
		--Programa = pa.NombrePrograma,
		--DescripcionActividadPetrolera = UPPER(ap.DescripcionActividadPetrolera),
		--SubactividadPetrolera = upper(sap.SubactividadPetrolera),
		--TareaPetrolera = upper(tp.TareaPetrolera),
		reg.DescripcionActividadPetrolera,
		reg.SubactividadPetrolera,
		reg.TareaPetrolera,
--		s.IdServicio,
		--SubTareaPetrolera = upper(isnull(s.NombreServicio,'')),
		reg.SubTareaPetrolera,
		--Anio = datepart(year,reg.FecMovto),
		--Mes  = datePart(Month,reg.FecMovto),
		Anio = DATEPART(YEAR, T.FechaPago),
		Mes = DATEPART(MONTH, T.FechaPago),
		--Monto = reg.MontoRegistro,
		--Monto = SUM(TR.MontoPagado),
		Monto = SUM(CASE
            WHEN T.IdMoneda = 1 --F.IdMoneda = 1
            THEN CASE   WHEN isnull(tc.TipoCambio, 0) > 0
						THEN TR.MontoPagado / tc.TipoCambio
                        ELSE 0
                    END
			ELSE TR.MontoPagado
        END)
--		reg.IdRegistro		
	into #tmpPaso1	
	--from CO_Contrato c
	--inner join CO_PeriodoContrato pc on pc.idContrato = c.idContrato
	--inner join [dbo].[CO_AnioContractual] anioC on anioC.IdContrato =  pc.idContrato
	----inner join CO_AnioContractual ac on ac.IdContrato = pc.idContrato
	--inner join CO_Presupuesto pre on pre.IdAnioContractual = anioC.IdAnioContractual
	--INNER JOIN CO_LineaPresupuestoMes pam on pam.IdPresupuesto = pre.IdPresupuesto
	----inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
	--inner join CO_ActividadPetroleraCNH ap on ap.IdActividadPetrolera = pam.IdActividadPetrolera
	--inner join CO_SubactividadPetrolera sap on sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
	--inner join dbo.CO_TareaPetrolera tp on tp.IdTareaPetrolera = pam.IdTareaPetrolera
	--left join [dbo].CO_Servicio s on s.IdServicio = pam.IdSubactividad 
	--inner join CO_Registro reg on reg.IdPrograma = pam.IdLineaPresupuestoMes
	FROM
--	JOIN
		#Facturas	REG
		--ON	pam.IdLineaPresupuestoMes	=	REG.IdLineaPresupuestoMes
	JOIN dbo.FI_Factura	F
		ON	REG.IdFactura	=	F.IdFactura
	JOIN dbo.FI_TransferFactura	TR
		ON	F.IdFactura	=	TR.IdFactura
	JOIN dbo.FI_Transfer	T
			ON	TR.IdTransfer	=	T.IdTransferencia
	LEFT JOIN [dbo].[CO_TipoCambioDiario] TC 
		ON TC.IdMoneda = T.idmoneda	--TC.IdMoneda = F.idmoneda
         --AND CONVERT( VARCHAR, F.Fecha, 112) = CONVERT(VARCHAR, TC.Fecha, 112)
		 AND CONVERT( VARCHAR, T.FechaPago, 112) = CONVERT(VARCHAR, TC.Fecha, 112)
--	WHERE
--		C.IdContrato = @pidContrato and
	--DATEPART(year,reg.FecMovto) = @pAnio
--		DATEPART(YEAR,T.FechaPago) = @pAnio
	GROUP BY
--		pam.IdLineaProgramaActividadMes,
--		pam.IdActividadPetrolera,
--		pam.IdSubactividadPetrolera,
--		pam.IdTareaPetrolera,
--		pam.IdSubactividad,
--		UPPER(ap.DescripcionActividadPetrolera),
--		upper(sap.SubactividadPetrolera),
--		upper(tp.TareaPetrolera),
----		s.IdServicio,
--		upper(isnull(s.NombreServicio,'')),
		REG.IdActividadPetrolera,
		REG.IdSubactividadPetrolera,
		REG.IdTareaPetrolera,
		REG.IdSubactividad,
		reg.DescripcionActividadPetrolera,
		reg.SubactividadPetrolera,
		reg.TareaPetrolera,
		reg.SubTareaPetrolera,
		DATEPART(YEAR, T.FechaPago),
		DATEPART(MONTH, T.FechaPago)
		--reg.IdRegistro		


	--Por mes
	select
		--Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--IdServicio,
		SubTareaPetrolera ,
		Enero = sum(case when Mes = 1 then Monto else 0 end ),
		Febrero = sum(case when Mes = 2 then Monto else 0 end ),
		Marzo = sum(case when Mes = 3 then Monto else 0 end ),
		Abril= sum(case when Mes = 4then Monto else 0 end ),
		Mayo=sum(case when Mes = 5 then Monto else 0 end ),
		Junio=sum(case when Mes = 6 then Monto else 0 end ),
		Julio=sum(case when Mes = 7 then Monto else 0 end ),
		Agosto=sum(case when Mes = 8 then Monto else 0 end ),
		Septiembre=sum(case when Mes = 9 then Monto else 0 end ),
		Octubre = sum(case when Mes = 10 then Monto else 0 end) ,
		Noviembre=sum(case when Mes = 11 then Monto else 0 end),
		Diciembre = sum(case when Mes = 12 then Monto else 0 end)
	from #tmpPaso1
	--group by IdLineaProgramaActividadMes,
	--	IdProgramaActividad,
	--	IdActividadPetrolera,
	--	IdSubactividadPetrolera,
	--	IdTareaPetrolera,
	--	IdSubTareaPetrolera,
	group by
		--Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--dServicio,
		SubTareaPetrolera
	order by --Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--dServicio,
		SubTareaPetrolera

		--Totales
	select
		--Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--IdServicio,
		SubTareaPetrolera ,
		Total = sum(Monto)
	from #tmpPaso1
	--group by IdLineaProgramaActividadMes,
	--	IdProgramaActividad,
	--	IdActividadPetrolera,
	--	IdSubactividadPetrolera,
	--	IdTareaPetrolera,
	--	IdSubTareaPetrolera,
	group by
		--Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--dServicio,
		SubTareaPetrolera
	order by --Programa ,
		DescripcionActividadPetrolera ,
		SubactividadPetrolera ,
		TareaPetrolera ,
		--dServicio,
		SubTareaPetrolera

