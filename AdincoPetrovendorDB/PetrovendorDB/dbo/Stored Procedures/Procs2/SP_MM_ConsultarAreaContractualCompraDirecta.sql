-- =============================================
-- Author:Daniel AC
-- Create date: 06-04-2018
-- Description:	Buscar el nombre del contrato por el IdOperacion de la compra directa
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarAreaContractualCompraDirecta] 
    -- Add the parameters for the stored procedure here   
    @IdOperacion INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.


	SELECT  
	ISNULL(AC.NombreAreaContractual,''),
    ISNULL(C.NumeroContrato,''),
    (C.NumeroContrato + ' - ' + AC.NombreAreaContractual) AS Contrato 
	FROM Petrovendor.dbo.TA_Operacion O
	INNER JOIN Petrovendor.dbo.FI_Factura F ON F.IdFactura= O.IdDocumento
	INNER JOIN Adinco.dbo.CO_Contrato C ON  F.IdContrato= C.IdContrato
	INNER JOIN Adinco.dbo.CO_AreaContractual AC
            ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE IdOperacion= @IdOperacion


END;
