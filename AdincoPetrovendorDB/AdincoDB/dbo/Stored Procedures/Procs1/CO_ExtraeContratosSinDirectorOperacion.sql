-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/2018
-- Description:	Extrae los contratos los cuanles no tengan asignados un director de operacion
-- =============================================
CREATE PROCEDURE CO_ExtraeContratosSinDirectorOperacion
	-- Add the parameters for the stored procedure here
	@idusuario int =0,
	@idContrato int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT  CC.idContrato as idContrato, NumeroContrato as NumeroContrato From
CO_Contrato CC
Left Join CO_DirectorContrato CD on CC.idContrato=CD.idContrato
Where CD.idContrato is null

END

