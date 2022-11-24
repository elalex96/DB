-- =============================================  
-- Author:Daniel AC  
-- Create date: 22-01-2017  
-- Description: Buscar el nombre del contrato por la solicitud de pedido, si no se encuentra retornar textos vacios   
-- =============================================  
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarContratosPorIdSolicitudPedido]   
    -- Add the parameters for the stored procedure here  
     
    @IdSolicitudPedido INT  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
  
 DECLARE @NombreAreaContractual NVARCHAR(MAX)  
 DECLARE @NumeroContrato NVARCHAR(MAX)  
 DECLARE @Contrato NVARCHAR(MAX)  
  
  
    SELECT DISTINCT  
        @NombreAreaContractual=ISNULL(AC.NombreAreaContractual,''),  
        @NumeroContrato=ISNULL(C.NumeroContrato,''),  
        @Contrato=(CONCAT(ISNULL(C.NumeroContrato,''),' - ',ISNULL(AC.NombreAreaContractual,'')))         
    FROM Adinco.dbo.CO_Contrato C (NOLOCK)
        INNER JOIN Adinco.dbo.CO_AreaContractual AC (NOLOCK) 
            ON C.IdAreaContractual = AC.IdAreaContractual  
  INNER JOIN Petrovendor.dbo.MM_SolicitudPedido SP (NOLOCK) ON sp.IdContrato= C.IdContrato  
    WHERE (SP.IdSolicitudPedido = @IdSolicitudPedido);  
   
 SELECT   
 ISNULL(@NombreAreaContractual,'') AS NombreAreaContractual,  
 ISNULL(@NumeroContrato,'') AS NombreAreaContractual,  
 ISNULL(@Contrato,'') AS Contrato  
  
   
  
END;