-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018/10/16
-- Description:	Extrae los tipo de fluido para petroleo
-- =============================================
CREATE PROCEDURE PR_ExtraeFluidoPetroleo
@IdUsuario INT,
@IdContrato INT

AS
BEGIN
	SET NOCOUNT ON;
SELECT DISTINCT(TipoFluidoPetroleo) AS fluido FROM pr_pozo WHERE TipoFluidoPetroleo IS NOT NULL AND TipoFluidoPetroleo <>'0'
END
