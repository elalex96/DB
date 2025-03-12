IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_ServiciosPresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_UPD_CO_ServiciosPresupuestoCIEP;
GO
CREATE PROCEDURE USP_INS_UPD_CO_ServiciosPresupuestoCIEP
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT
AS
BEGIN
  
SET NOCOUNT ON;
 
CREATE TABLE #TablaTemporalValidacionServicio
    (
        NombreServicio    VARCHAR(3000) NULL,
        Activo            BIT           NULL,
        IdServicio        INT           NULL
    )

DECLARE
    @IdCarga                INT = 0,
    @IdContratoSeleccionado INT = 0,
	@ErrorMessage VARCHAR(8000) ='',
	@IdUnidad INT = 13;

BEGIN TRY
Select
    @IdCarga                = IdCarga,
    @IdContratoSeleccionado = IdContrato
FROM
    CO_BitacoraPresupuesto	(NOLOCK)
where
    IdArchivoAWS = @IdArchivoAWS;

-- SERVICIOS DE LA CARGA DEL LAYOUT
INSERT INTO #TablaTemporalValidacionServicio
    (
        NombreServicio
    )
            SELECT
              DISTINCT RTRIM(LTRIM(Servicios))
            FROM
                CO_BitacoraPresupuestoDetalleCIEP (NOLOCK)
            WHERE
                IdCarga = @IdCarga;



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
            ON UPPER(#TablaTemporalValidacionServicio.NombreServicio) = UPPER(LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))))
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
