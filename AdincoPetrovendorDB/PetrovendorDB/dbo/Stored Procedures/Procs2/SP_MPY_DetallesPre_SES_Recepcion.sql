DROP PROCEDURE IF EXISTS SP_MPY_DetallesPre_SES_Recepcion
GO
-- =============================================  
-- Author:  ALexander Gomez  
-- Create date: 29/10/2018  
 -- Description: Consulta de los detalles de la PRE-SES  
-- =============================================  
-- Author:  LUIS DAVID
-- Create date: 26/08/2021
 -- Description: SE AGREGA EL BUCKET A LA CONSULTA
-- =============================================  
CREATE PROCEDURE [dbo].[SP_MPY_DetallesPre_SES_Recepcion]  
 -- Add the parameters for the stored procedure here  
 @IdPRESES NVARCHAR(20)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 SELECT  
  PSES.IdPRESES,--0  
  PSES.IdEstatus,--1  
  V.VendorName + ' - ' + V.VendorIDSAP AS Vendor,--2  
  PSES.SAPPONumber,--3  
  DOCPRESES.NombreDoc,--4  
  DOCPRESES.Identificador,--5  
  DOCPRESES.Extension,--6  
  DOCPRESES.Mime,--7  
  DOCPRESES.Carpeta,--8,  
  PSES.CreadoEl,--9  
  --DATOS DE APROBACION  
  PSES.ModificadoEl,--10  
  US.Nombre,--11  
  PSES.Justificacion,--12  
  ISNULL(PSES.SAPSESNumber,''),--13  
  PSES.MontoTotalPrefactura,--14  
  CASE   
   WHEN PSES.IdEstatus = 2 THEN ISNULL(SES.SESNumber,'Without SES Associated')  
   ELSE 'Without SES Associated'  
  END,  
  ISNULL(PSES.ComentarioInterno,'') ,
  ISNULL(DOCPRESES.Bucket, '') AS Bucket
 FROM Adinco.dbo.CO_SAPPRESES AS PSES  
  LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber  
  LEFT JOIN Adinco.dbo.MPY_DocumentosPRESES AS DOCPRESES ON DOCPRESES.IdPRESES = PSES.IdPRESES  
  LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = PSES.ModificadoPor  
  --LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber  
  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESNumber = PSES.SESN  
 WHERE PSES.IdPRESES = @IdPRESES  
 --AND DOCPRESES.IdTipoDocumento = 1  
 GROUP BY V.VendorName + ' - ' + V.VendorIDSAP,  
             ISNULL(PSES.SAPSESNumber, ''),  
             ISNULL(SES.SESNumber, 'Without SES Associated'),  
             ISNULL(PSES.ComentarioInterno,''),  
             PSES.IdPRESES,  
             PSES.IdEstatus,  
             PSES.SAPPONumber,  
             DOCPRESES.NombreDoc,  
             DOCPRESES.Identificador,  
             DOCPRESES.Extension,  
             DOCPRESES.Mime,  
             DOCPRESES.Carpeta,  
			 DOCPRESES.Bucket,
             PSES.CreadoEl,  
             PSES.ModificadoEl,  
             US.Nombre,  
             PSES.Justificacion,  
             PSES.MontoTotalPrefactura  
  
END
