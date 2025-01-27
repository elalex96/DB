IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ActualizarFechaFin'
    )
    DROP PROCEDURE p_OT_ActualizarFechaFin;
GO
CREATE PROC p_OT_ActualizarFechaFin
    @pIdOTSolicitud     INT,
    @pFechaFinExtendida DATETIME
AS
BEGIN

    /*********Validar***********/
    DECLARE
        @pFechaFinOriginal DATETIME,
        @FechaMaxCaptura   datetime,
        @error             varchar(250)

    select
        @pFechaFinOriginal = FechaFin
    FROM
        OT_Solicitud (NOLOCK)
    where
        IdOTSolicitud = @pIdOTSolicitud

    if (convert(varchar, @pFechaFinExtendida, 112) <= convert(VARCHAR, @pFechaFinOriginal, 112))
        BEGIN
            RAISERROR('La fecha extendida no puede ser menor o igual a la fecha original', 16, 1)
            return
        END

    SELECT
        @FechaMaxCaptura = max(spc.Fecha)
    FROM
	 dbo.OT_SolicitudMaterial    sm	(NOLOCK)
	JOIN
            dbo.OT_SolicitudPrograma    sp	(NOLOCK)
			 ON sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
			   AND	sm.IdOTSolicitud = @pIdOTSolicitud
                
     JOIN
			dbo.OT_SolicitudProgramaCaptura spc	(NOLOCK)
			ON sp.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial 
    WHERE
        sm.IdOTSolicitud = @pIdOTSolicitud
        AND spc.Captura > 0

    IF @pFechaFinExtendida < @FechaMaxCaptura
        BEGIN
            set @error = 'Fecha no válida , ya existen capturas hasta el:' + convert(varchar, @FechaMaxCaptura, 103)
            RAISERROR(@error, 16, 1)
            return
        END

    UPDATE
        dbo.OT_Solicitud
    SET
        fechaFinExtendida = @pFechaFinExtendida
    WHERE
        IdOTSolicitud = @pIdOTSolicitud

END