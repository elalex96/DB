IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_RubrosPresupuestoCIEP'
    )
    DROP PROCEDURE USP_INS_UPD_CO_RubrosPresupuestoCIEP;
GO
CREATE PROCEDURE USP_INS_UPD_CO_RubrosPresupuestoCIEP
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT
AS
BEGIN
  
SET NOCOUNT ON;
 
CREATE TABLE #TablaTemporalValidacion
    (
       Nombre  VARCHAR(1000) NULL,
		Id INT           NULL,
		Activo              BIT           NULL
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
    CO_BitacoraPresupuesto	(NOLOCK)
where
    IdArchivoAWS = @IdArchivoAWS;

-- SERVICIOS DE LA CARGA DEL LAYOUT
INSERT INTO #TablaTemporalValidacion
    (
        Nombre
    )
            SELECT
              DISTINCT RTRIM(LTRIM(Rubro))
            FROM
                CO_BitacoraPresupuestoDetalleCIEP (NOLOCK)
            WHERE
                IdCarga = @IdCarga;

-- VERIFICACIÓN DE EXISTRENCIA DE SERVICIOS 
UPDATE
    #TablaTemporalValidacion
SET
    #TablaTemporalValidacion.Activo = ISNULL(CO_Rubro.Activo, 0),
    #TablaTemporalValidacion.Id = CO_Rubro.IdRubro
FROM
    #TablaTemporalValidacion
    JOIN
        CO_Rubro
            ON UPPER(#TablaTemporalValidacion.Nombre) = UPPER(LTRIM(RTRIM(ISNULL(CO_Rubro.NombreRubro, ''))))

-- SERVICIOS ACTIVACIÓN 
UPDATE
    CO_Rubro
SET
    CO_Rubro.Activo = 1,
    IdUsuario = @UsuarioId,
    FecMovto = GETDATE()
FROM
    #TablaTemporalValidacion
    JOIN
        CO_Rubro
            ON #TablaTemporalValidacion.Id = CO_Rubro.IdRubro
where
    #TablaTemporalValidacion.Id IS NOT NULL
    AND #TablaTemporalValidacion.Activo = 0;

INSERT INTO CO_Rubro
    (
	NombreRubro,
	IdUsuario,
	FecMovto,
	Activo,
	CreadoPor
    )
           Select
                Nombre,
                @UsuarioId,
                GETDATE(),
                1,
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
