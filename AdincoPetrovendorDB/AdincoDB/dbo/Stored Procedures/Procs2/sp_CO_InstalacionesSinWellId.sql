-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180823
-- Description:	Trae las instalaciones que no estan a�adidas en la tabla de PR_pozo
-- =============================================
create PROCEDURE sp_CO_InstalacionesSinWellId
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT IdInstalacion,
           NombreInstalacion
    FROM dbo.CO_Instalacion
	JOIN dbo.CO_Contrato ON CO_Contrato.IdAreaContractual = CO_Instalacion.IdAreaContractual

    WHERE (
              WelIID IS NULL
              OR WelIID = 0
          )
          AND IdActividad = 5
		  AND IdContrato=@IdContrato;

END;