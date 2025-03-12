IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_ActividadesPresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_UPD_CO_ActividadesPresupuestoCIEP;
GO
CREATE PROCEDURE USP_INS_UPD_CO_ActividadesPresupuestoCIEP
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
              DISTINCT RTRIM(LTRIM(Actividad))
            FROM
                CO_BitacoraPresupuestoDetalleCIEP (NOLOCK)
            WHERE
                IdCarga = @IdCarga;

-- VERIFICACIÓN DE EXISTRENCIA DE SERVICIOS 
UPDATE
    #TablaTemporalValidacion
SET
    #TablaTemporalValidacion.Id = CO_ActividadCIEP.IdActividad
FROM
    #TablaTemporalValidacion
    JOIN
        CO_ActividadCIEP
            ON UPPER(#TablaTemporalValidacion.Nombre) = UPPER(LTRIM(RTRIM(ISNULL(CO_ActividadCIEP.NombreActividad, ''))))
			AND CO_ActividadCIEP.IdContrato = @IdContratoSeleccionado

INSERT INTO CO_ActividadCIEP
    (
NombreActividad,
IdContrato,
IdUsuarioCreadoPor,
Creado,
CreadoPor
    )
           Select
                Nombre,
                @IdContratoSeleccionado,
				@UsuarioId,
                GETDATE(),
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
