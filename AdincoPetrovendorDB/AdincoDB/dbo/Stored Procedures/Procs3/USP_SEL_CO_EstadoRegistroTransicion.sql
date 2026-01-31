IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_CO_EstadoRegistro_PorContrato'
		)
	DROP PROCEDURE USP_SEL_CO_EstadoRegistro_PorContrato;
GO
CREATE PROCEDURE dbo.USP_SEL_CO_EstadoRegistro_PorContrato
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
           E.IdClvEstado AS IdEstadoDestino,
           E.NombreEstado AS CambiarA
    FROM dbo.CO_EstadoRegistro_V2 E WITH (NOLOCK)
    WHERE E.IdContrato = @IdContrato
      AND E.Activo = 1

END;



