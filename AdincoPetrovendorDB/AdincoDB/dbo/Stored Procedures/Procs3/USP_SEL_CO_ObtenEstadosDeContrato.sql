IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenEstadosDeContrato'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenEstadosDeContrato;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenEstadosDeContrato]--1,10,10007
 @IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdContratoSeleccion	INT
AS
    BEGIN
			SELECT DISTINCT 
                IdEstado,
                IdClvEstado,
				NombreEstado,
				Descripcion
				FROM 
					CO_EstadoRegistro_V2(NOLOCK)
				WHERE CO_EstadoRegistro_V2.IdContrato = @IdContratoSeleccion
				ORDER BY  CO_EstadoRegistro_V2.NombreEstado ASC
	END;
