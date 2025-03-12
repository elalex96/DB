IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_ClasificacionesPresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_UPD_CO_ClasificacionesPresupuestoCIEP;
GO
CREATE PROCEDURE USP_INS_UPD_CO_ClasificacionesPresupuestoCIEP
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT
AS
BEGIN
  
SET NOCOUNT ON;
 
CREATE TABLE #TablaTemporalValidacion
    (
       Nombre  VARCHAR(1000) NULL,
		Id INT           NULL
    )

DECLARE
    @IdCarga                INT = 0,
    @IdContratoSeleccionado INT = 0,
	@ErrorMessage VARCHAR(8000) =''

BEGIN TRY
Select
    @IdCarga                = IdCarga,
    @IdContratoSeleccionado = IdContrato
FROM
    CO_BitacoraPresupuesto
where
    IdArchivoAWS = @IdArchivoAWS;

INSERT INTO #TablaTemporalValidacion
    (
        Nombre
    )
            SELECT
              DISTINCT RTRIM(LTRIM(Clasificacion))
            FROM
                CO_BitacoraPresupuestoDetalleCIEP (NOLOCK)
            WHERE
                IdCarga = @IdCarga;

-- VERIFICACIÓN DE EXISTRENCIA DE SERVICIOS 
UPDATE
    #TablaTemporalValidacion
SET
    #TablaTemporalValidacion.Id = CO_Clasificacion.IdClasificacion
FROM
    #TablaTemporalValidacion
    JOIN
        CO_Clasificacion
            ON UPPER(#TablaTemporalValidacion.Nombre) = UPPER(LTRIM(RTRIM(ISNULL(CO_Clasificacion.NombreClasificacion, ''))));

INSERT INTO CO_Clasificacion
    (
		NombreClasificacion,
		CreadoPor
    )
           Select
                Nombre,
                @UsuarioId
            from
                #TablaTemporalValidacion
            where
                Id IS NULL
				AND RTRIM(LTRIM(Nombre) ) <> '' AND  RTRIM(LTRIM(Nombre) ) <> '-';
 END TRY
    BEGIN CATCH
	
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END
