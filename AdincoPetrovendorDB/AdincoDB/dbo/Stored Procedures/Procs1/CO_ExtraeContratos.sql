IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'CO_ExtraeContratos'
)
    DROP PROCEDURE CO_ExtraeContratos
GO
-- =============================================
-- Author:	Reyna Olvera
-- Create date: 10/08/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeContratos]
	-- Add the parameters for the stored procedure here
	@idUsuario INT=0,
	@idcontrato INT =0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT idContrato, NumeroContrato 
	FROM  CO_Contrato (NOLOCK)
	ORDER BY NumeroContrato
END