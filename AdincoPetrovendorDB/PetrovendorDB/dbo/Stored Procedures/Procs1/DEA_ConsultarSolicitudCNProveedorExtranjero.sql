-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar proveedores extranjeros con permiso de cargar CNs por contrato
-- =============================================
CREATE PROCEDURE [dbo].[DEA_ConsultarSolicitudCNProveedorExtranjero]
	-- Add the parameters for the stored procedure here
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

	SELECT SCNPE.Id,P.IdProveedor, P.RFC, CONCAT(P.RazonSocial,' [',P.IdProveedor,']') AS Proveedor,CONCAT(C.NumeroContrato,ISNULL(' - '+AC.NombreAreaContractual,'')) AS Contrato,SCNPE.CreadoEl,SCNPE.IdContrato
	FROM DEA_SolicitudCNProveedorExtranjero SCNPE	
	JOIN S_Proveedor P
		ON SCNPE.IdProveedor = P.IdProveedor
	JOIN Adinco..CO_Contrato C
	ON SCNPE.IdContrato = C.IdContrato	
	LEFT JOIN Adinco..CO_AreaContractual AC
	ON C.IdAreaContractual =AC.IdAreaContractual
	WHERE SCNPE.Activo = 1
	ORDER BY P.RazonSocial ASC 

END
