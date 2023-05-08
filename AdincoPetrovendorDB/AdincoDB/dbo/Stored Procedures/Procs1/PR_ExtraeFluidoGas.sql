-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018/10/16
-- Description:	Extrae los tipo de fluido para el gas
-- =============================================
CREATE PROCEDURE PR_ExtraeFluidoGas
@IdUsuario INT,
@IdContrato INT
AS
BEGIN
	SET NOCOUNT ON;
SELECT DISTINCT(TipoFluidoGas) AS fluido FROM pr_pozo WHERE TipoFluidoGas IS NOT NULL AND TipoFluidoGas <>'0'
END
