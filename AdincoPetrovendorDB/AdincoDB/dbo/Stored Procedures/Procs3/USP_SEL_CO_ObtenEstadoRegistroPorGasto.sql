IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenEstadoRegistroPorGasto'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenEstadoRegistroPorGasto;
GO
CREATE PROC [dbo].[USP_SEL_CO_ObtenEstadoRegistroPorGasto]
    @IdUsuario INT,
    @IdContrato INT,
    @IdGasto INT
AS
BEGIN
  DECLARE @EstadoRegistro VARCHAR(100) = 'Revisión'; -- En revisión cuando no contiene registro en CO_RegistroMarkup

SELECT
   @EstadoRegistro  =   ERV2.NombreEstado
FROM
    CO_Registro              D (NOLOCK)
    JOIN
        CO_RegistroMarkup    RM (NOLOCK)
            ON D.IdRegistro = RM.GastoId
               AND IdRegistro = @IdGasto
               AND RM.IdEstadoPemex IS NOT NULL
    JOIN
        CO_EstadoRegistro_V2 ERV2   (NOLOCK)
            ON ERV2.Idcontrato = @IdContrato
               AND 
               RM.IdEstadoPemex = ERV2.IdClvEstado;

SELECT @EstadoRegistro AS Estado

END;

