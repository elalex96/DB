USE [Adinco]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_Facturas_Pdfviewer_Mostrarpdf'
)
    DROP PROCEDURE Sp_Facturas_Pdfviewer_Mostrarpdf;
GO


CREATE PROCEDURE [dbo].[Sp_Facturas_Pdfviewer_Mostrarpdf] 
	@IDFACTURA INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    SELECT IDFACTURA,
           DocumentoByte
    FROM FI_Documento (NOLOCK)
    WHERE IDFACTURA = @IDFACTURA
END