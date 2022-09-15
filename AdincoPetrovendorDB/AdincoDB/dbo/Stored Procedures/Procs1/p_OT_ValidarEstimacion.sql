--=======================================
-- Modificador: Neri del Angel
-- Fecha: 13 de Septiembre del 2022
-- Detalle: Se elimina codigo comentado, se ajusta orden de joins y en los ON de los joins
--=======================================
CREATE proc [dbo].[p_OT_ValidarEstimacion]
    @pIdOTEstimacion int,
    @pIdOTSolicitud int,
    @pFechaEstimacionIni datetime,
    @pFechaEstimacionFin datetime
as
begin
    /********Validar que las fechas del periodo de estimacion ya esten cerradas*****************/
    declare @fechaAux datetime,
            @error varchar(1000) = '',
            @warning bit = 0;
    set @fechaAux = @pFechaEstimacionIni

    while convert(varchar, @fechaAux, 112) <= convert(varchar, @pFechaEstimacionFin, 112)
    begin
        if not exists
        (
            select 1
            from [dbo].[OT_ProgramaSemanaCerrada] (NOLOCK)
            where IdOTSolicitud = @pIdOTSolicitud
                  and @fechaAux
                  between FechaSemanaIni and FechaSemanaFin
                  and isActivo = 1
        )
        Begin
            set @error = @error + convert(varchar, @fechaAux, 103) + ','
        end
        set @fechaAux = dateadd(day, 1, @fechaAux)
    end

    if (@error <> '')
    begin
        set @error
            = 'Es necesario ir a la captura de actividades, y cerrar las semanas para los siguientes días:' + @error
        set @warning = 1
    end
    --Validar que no se empalmen las fechas con otra estimación generada
    if exists
    (
        select 1
        from OT_Estimacion (NOLOCK)
        where IdOTSolicitud = @pIdOTSolicitud
              and (
                      convert(varchar, FechaCorteInicio, 112)
              between convert(varchar, @pFechaEstimacionIni, 112) and convert(varchar, @pFechaEstimacionFin, 112)
                      OR convert(varchar, FechaCorteFin, 112)
              between convert(varchar, @pFechaEstimacionIni, 112) and convert(varchar, @pFechaEstimacionFin, 112)
                  )
              and isnull(cancelada, 0) = 0
    )
    begin
        set @error
            = @error + '. No es posible generar la estimación, se empalmarían fechas con otra estimación generadas'
        set @warning = 0
    end
    --Validar que la Estimación tenga un importe mayor  cero
    if
    (
        select ISNULL(SUM(Captura), 0)
        from [dbo].[OT_SolicitudProgramaCaptura] pc (NOLOCK)
            inner join OT_SolicitudMaterial sm (NOLOCK)
                on PC.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
        where SM.IdOTSolicitud = @pIdOTSolicitud
              and (convert(varchar, Fecha, 112)
              between convert(varchar, @pFechaEstimacionIni, 112) and convert(varchar, @pFechaEstimacionFin, 112)
                  )
              AND VoBoSubcontratista = 1
              AND VoBoContratista = 1
    ) = 0
    begin
        set @error = @error + '. No es posible generar la estimación, El importe debe de ser mayor cero'
        set @warning = 0
    end

    if (convert(varchar, @pFechaEstimacionIni, 112) > convert(varchar, @pFechaEstimacionFin, 112))
    begin
        set @error = @error + '. La fecha de corte inicial no puede ser mayor a la final'
        set @warning = 0
    end

    select error = @error,
           warning = @warning
end