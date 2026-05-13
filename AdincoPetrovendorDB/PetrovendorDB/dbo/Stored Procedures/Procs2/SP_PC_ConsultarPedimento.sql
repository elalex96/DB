-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Consultar pedimento
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultarPedimento]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdPedimentoComprobante INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT 
	PC.NumeroPedimento, 
	PC.ClavePedimento,
	PC.FolioComprobante,
	CL.IdClavePedimento,
	PC.FechaPago,
	PC.Regimen,
	PC.AduanaES,		
	CvTipoDocFacturacion,
	D.IdDocumento,
	D.NombreExtensionArchivo,
	PC.AcuseElectronico,
	D.DocumentoByte
	FROM dbo.FI_PedimentoComprobante PC
	LEFT JOIN [Adinco].[dbo].FI_ClavesPedimento C ON C.IdPedimento=PC.ClavePedimento
	LEFT JOIN [Adinco].[dbo].FI_ClavesPedimentoLista CL ON CL.IdClavePedimento=C.IdClavePedimento
	LEFT JOIN dbo.FI_Documento D ON D.IdPedimentoComprobante= PC.IdPedimentoComprobante
	WHERE PC.IdPedimentoComprobante=@IdPedimentoComprobante
	 

END;

 