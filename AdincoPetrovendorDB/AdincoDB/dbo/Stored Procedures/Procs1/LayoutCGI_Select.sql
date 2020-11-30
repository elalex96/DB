CREATE PROCEDURE LayoutCGI_Select
AS
BEGIN
    SELECT l.IdCGILayout,
           l.CompanyCode,
           l.DocumentType,
           l.Documento,
           l.FiscalYear,
           l.PostingPeriod,
           l.PostingDate,
           l.DocumentDate,
           l.JointVenture,
           l.AccountNumber,
           l.AreaContractual,
           l.Texto,
           l.WBSElement,
           l.CostCenter,
           l.TransactionAmount,
           l.TransactionCurrency,
           l.JoinOperAgreem,
           l.LocalAmount,
           l.Subtotal,
           l.LocalCurrency,
           l.Vendor,
           l.CreadoEl,
           u.Nombre CreadoPor FROM  dbo.CGI_Layout l LEFT JOIN dbo.AP_Usuario u ON u.UsuarioID = l.CreadoPor 
		   WHERE l.Activo = 1 ORDER BY l.CreadoEl DESC	 
END;