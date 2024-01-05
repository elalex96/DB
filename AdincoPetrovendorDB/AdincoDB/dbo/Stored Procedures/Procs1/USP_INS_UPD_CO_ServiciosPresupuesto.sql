
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_ServiciosPresupuesto'
    )
    DROP PROCEDURE USP_INS_UPD_CO_ServiciosPresupuesto
GO
CREATE PROCEDURE USP_INS_UPD_CO_ServiciosPresupuesto
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT
AS
BEGIN
  
SET NOCOUNT ON;
 
CREATE TABLE #TablaTemporalValidacionServicio
    (
        IdSubtarea        VARCHAR(100)  NULL,
        Subtarea_Servicio VARCHAR(1000) NULL,
        NombreServicio    VARCHAR(3000) NULL,
        Activo            BIT           NULL,
        IdServicio        INT           NULL
    )

DECLARE
    @IdCarga                INT = 0,
    @AdjuntarClaveSubtarea  INT = 0,
    @IdContratoSeleccionado INT = 0,
    @IdUnidad               INT = 13,
	@ErrorMessage VARCHAR(8000) ='';

BEGIN TRY
Select
    @IdCarga                = IdCarga,
    @AdjuntarClaveSubtarea  = chkAdjuntaClaveSubTarea,
    @IdContratoSeleccionado = IdContrato
FROM
    CO_BitacoraPresupuesto
where
    IdArchivoAWS = @IdArchivoAWS;

-- SERVICIOS DE LA CARGA DEL LAYOUT
INSERT INTO #TablaTemporalValidacionServicio
    (
        IdSubtarea,
        Subtarea_Servicio,
        NombreServicio,
        Activo
    )
            SELECT
                CASE
                    WHEN @AdjuntarClaveSubtarea = 1
                        THEN IdSubtarea
                    ELSE
                        ''
                END,
                Subtarea_Servicio,
                CASE
                    WHEN @AdjuntarClaveSubtarea = 1
                        THEN LTRIM(RTRIM(CONCAT(
                                                   CO_BitacoraPresupuestoDetalle.IdSubtarea, '-',
                                                   CO_BitacoraPresupuestoDetalle.Subtarea_Servicio
                                               )
                                        )
                                  )
                    ELSE
                        Subtarea_Servicio
                END,
                0
            FROM
                CO_BitacoraPresupuestoDetalle (NOLOCK)
            WHERE
                IdCarga = @IdCarga
            GROUP BY
                CASE
                    WHEN @AdjuntarClaveSubtarea = 1
                        THEN IdSubtarea
                    ELSE
                        ''
                END,
                Subtarea_Servicio,
                CASE
                    WHEN @AdjuntarClaveSubtarea = 1
                        THEN LTRIM(RTRIM(CONCAT(
                                                   CO_BitacoraPresupuestoDetalle.IdSubtarea, '-',
                                                   CO_BitacoraPresupuestoDetalle.Subtarea_Servicio
                                               )
                                        )
                                  )
                    ELSE
                        Subtarea_Servicio
                END



-- VERIFICACIÓN DE EXISTRENCIA DE SERVICIOS 
UPDATE
    #TablaTemporalValidacionServicio
SET
    #TablaTemporalValidacionServicio.Activo = ISNULL(CO_Servicio.Activo, 0),
    #TablaTemporalValidacionServicio.IdServicio = CO_Servicio.IdServicio
FROM
    #TablaTemporalValidacionServicio
    JOIN
        CO_Servicio
            ON #TablaTemporalValidacionServicio.NombreServicio = LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, '')))
WHERE
    CO_Servicio.IdContrato = @IdContratoSeleccionado;

-- SERVICIOS ACTIVACIÓN 
UPDATE
    CO_Servicio
SET
    CO_Servicio.Activo = 1,
    ModificadoPor = @UsuarioId,
    ModificadoEl = GETDATE()
FROM
    #TablaTemporalValidacionServicio
    JOIN
        CO_Servicio
            ON #TablaTemporalValidacionServicio.IdServicio = CO_Servicio.IdServicio
where
    #TablaTemporalValidacionServicio.IdServicio IS NOT NULL
    AND #TablaTemporalValidacionServicio.Activo = 0;

	-- REGSTRO DE SERVICIOS NUEVOS
INSERT INTO CO_Servicio
    (
        IdContrato,
        NombreServicio,
        IdUnidad,
        IdUsuario,
        FecMovto,
        Activo,
        CreadoPor
    )
            Select
                @IdContratoSeleccionado,
                NombreServicio,
                @IdUnidad,
                @UsuarioId,
                GETDATE(),
                1,
                @UsuarioId
            from
                #TablaTemporalValidacionServicio
            where
                IdServicio IS NULL
				AND RTRIM(LTRIM(NombreServicio) ) <> '' AND  RTRIM(LTRIM(NombreServicio) ) <> '-';
 END TRY
    BEGIN CATCH
	
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END