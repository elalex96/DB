-- =============================================
-- Author:	Reyna Olvera
-- Create date: 10/08/2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE CO_ExtraeContratos
	-- Add the parameters for the stored procedure here
	@idUsuario INT=0,
	@idcontrato INT =0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT idContrato,NumeroContrato FROM  CO_Contrato 
END