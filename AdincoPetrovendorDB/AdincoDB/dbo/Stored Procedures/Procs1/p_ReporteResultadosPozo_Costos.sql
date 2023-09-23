USE [Adinco]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_ReporteResultadosPozo_Costos'
)
    DROP PROCEDURE p_ReporteResultadosPozo_Costos
GO
CREATE proc [dbo].[p_ReporteResultadosPozo_Costos]
    @pIdContrato int,
    @pIdPozo int,
    @pMes date,
    @pIdusuario int
AS
BEGIN
	
	CREATE TABLE #tmpAcumulado_Prev(
		Id INT,
		IdContrato INT,
		IdServicio INT,
		NombreServicio VARCHAR(8000),
		IdRegistro INT,
		Acumulado MONEY,
		MontoGasto DECIMAL(18, 4),
		Fecha DATETIME,
		IdMoneda INT,
		Paridad MONEY,
		Moneda VARCHAR(8000),
		MesPresentacion DATE
	)
	CREATE TABLE #tmpAcumulado(
		IdServicio INT,
		NombreServicio VARCHAR(8000),
		Total money,
		Acumulado money
	)
	CREATE TABLE #tmpMes(
		IdServicio INT, 
		NombreServicio VARCHAR(8000), 
		Total MONEY, 
		Acumulado MONEY
	)


    declare @pMesIniAnio date,
            @pMesFinAnio date

    select @pMesIniAnio = dateadd(month, - (datepart(month, @pMes) - 1), @pMes)

    set @pMesFinAnio = dateadd(month, 1, @pMes)
    set @pMesFinAnio = dateadd(day, -1, @pMesFinAnio)

	INSERT INTO #tmpAcumulado_Prev
    (
        Id,
        IdContrato,
        IdServicio,
        NombreServicio,
        IdRegistro,
        Acumulado,
        MontoGasto,
        Fecha,
        IdMoneda,
        Paridad,
        Moneda,
        MesPresentacion
    )
    SELECT PR_Pozo.Id,
           FI_Factura.IdContrato,
           CO_Servicio.IdServicio,
           CO_Servicio.NombreServicio,
           CO_Registro.IdRegistro,
           Acumulado = cast(0 as money),
           MontoGasto = CO_Registro.MontoRegistro,
           Fecha = FI_Factura.Fecha,
           IdMoneda = FI_Factura.IdMoneda,
           Paridad = cast(1 as money),
           FI_Factura.Moneda,
           CO_Registro.MesPresentacion
    FROM CO_Registro (NOLOCK)
        inner join FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura 
			and FI_Factura.IdContrato = @pIdContrato
			and CO_Registro.IdEstado = 10004 --Aprobado
        inner join CO_Instalacion (NOLOCK)
            ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion  
        inner join PR_Pozo (NOLOCK)
            ON CO_Instalacion.WelIID = PR_Pozo.Id 
			and PR_Pozo.Id = @pidPozo
        inner join CO_LineaPresupuestoMes (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
        inner join CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.idServicio  
    WHERE FI_Factura.IdContrato = @pIdContrato
          and PR_Pozo.Id = @pidPozo
          and convert(varchar, CO_Registro.MesPresentacion, 112) <= convert(varchar, @pMesFinAnio, 112)
          and CO_Registro.IdEstado = 10004 --Aprobado


    INSERT INTO #tmpAcumulado_Prev
    (
        Id,
        IdContrato,
        IdServicio,
        NombreServicio,
        IdRegistro,
        Acumulado,
        MontoGasto,
        Fecha,
        IdMoneda,
        Paridad,
        Moneda,
        MesPresentacion
    )
    select PR_Pozo.Id,
           FI_PedimentoComprobante.IdContrato,
           CO_Servicio.IdServicio,
           CO_Servicio.NombreServicio,
           CO_Registro.IdRegistro,
           Acumulado = cast(0 as money),
           MontoGasto = CO_Registro.MontoRegistro,
           Fecha = FI_PedimentoComprobante.FechaPago,
           IdMoneda = FI_PedimentoComprobante.IdMoneda,
           Paridad = cast(1 as money),
           PV_TipoMoneda.TipoMonedaCorto,
           CO_Registro.MesPresentacion
    from CO_Registro (NOLOCK)
        inner join FI_PedimentoComprobante (NOLOCK)
            on  CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
			and FI_PedimentoComprobante.IdContrato = @pIdContrato
			and CO_Registro.IdEstado = 10004 --Aprobado
        inner join CO_Instalacion (NOLOCK)
            on CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
        inner join PR_Pozo (NOLOCK)
            on CO_Instalacion.WelIID = PR_Pozo.Id
			and PR_Pozo.Id = @pidPozo
        inner join CO_LineaPresupuestoMes (NOLOCK)
            on CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        inner join CO_Servicio (NOLOCK)
            on CO_LineaPresupuestoMes.IdServicio = CO_Servicio.idServicio
        left join PV_TipoMoneda (NOLOCK)
            on FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    where FI_PedimentoComprobante.IdContrato = @pIdContrato
          and PR_Pozo.Id = @pidPozo
          and convert(varchar, CO_Registro.MesPresentacion, 112) <= convert(varchar, @pMesFinAnio, 112)
          and CO_Registro.IdEstado = 10004 --Aprobado



    update #tmpAcumulado_Prev
    set Paridad = TipoCambio
    from #tmpAcumulado_Prev prev
        inner join CO_TipoCambioDiario tc
            on prev.IdMoneda = tc.IdMoneda
               and convert(varchar, prev.Fecha, 112) = convert(varchar, tc.Fecha, 112)
               and tc.Activo = 1

    update #tmpAcumulado_Prev
    set Acumulado = MontoGasto / isnull(Paridad, 1)


	INSERT INTO #tmpAcumulado(IdServicio, NombreServicio, Acumulado)
    select IdServicio,
           NombreServicio,
           Acumulado = sum(Acumulado)
    from #tmpAcumulado_Prev
    group by IdServicio,
             NombreServicio




	INSERT INTO #tmpMes(IdServicio, NombreServicio, Total, Acumulado)
    select IdServicio,
           NombreServicio,
           Total = sum(Acumulado),
           Acumulado = 0
    from #tmpAcumulado_Prev
    where datepart(year, MesPresentacion) = datepart(year, @pMes)
          and datepart(month, MesPresentacion) = datepart(month, @pMes)
    group by IdServicio,
             NombreServicio


    select a.NombreServicio,
           Total = isnull(b.Total, 0),
           Acumulado = a.Acumulado
    from #tmpAcumulado a
        left join #tmpMes b
            on a.IdServicio = b.IdServicio 

END
