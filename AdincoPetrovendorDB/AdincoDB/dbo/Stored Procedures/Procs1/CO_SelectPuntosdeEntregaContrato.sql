-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description:	Extrae los putos de entrega-Contrato
-- =============================================
CREATE PROCEDURE CO_SelectPuntosdeEntregaContrato
	-- Add the parameters for the stored procedure here
	@idUsuario int =0,
	@idContrato int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PEC.PuntoEntregaContratoID as PuntoEntregaContratoID, PE.Nombre, PEC.PuntoEntregaID, 
   COC.NumeroContrato, PEC.idContrato FROM CO_PuntosdeEntregaContrato AS PEC 
   INNER JOIN CO_PuntosdeEntrega AS PE ON PEC.PuntoEntregaID = PE.PuntoEntregaID 
   INNER JOIN CO_Contrato AS COC ON PEC.idContrato = COC.IdContrato
	order by idContrato
END

