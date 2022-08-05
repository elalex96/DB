CREATE PROCEDURE [dbo].WDEAGuardarCuotaPatronal @IdCuotaPatronal int,
@DocType NVARCHAR(500), @Reverse NVARCHAR(100), @Reclass NVARCHAR(100), @RefDoc NVARCHAR(500), @DocCurrency NVARCHAR(100), @Concept NVARCHAR(500), @CompanyCode NVARCHAR(100), @PostingDate NVARCHAR(100), @RequestedBy NVARCHAR(200), @FiscalYear NVARCHAR(100), @Period NVARCHAR(100), @NombreArchivoImportado NVARCHAR(200), @IdUsuario INT, @IdContrato INT
AS
BEGIN
	INSERT INTO DEA_CuotaPatronal(DocType, Reverse, Reclass, RefDoc, DocCurrency, Concept, CompanyCode, PostingDate, RequestedBy, FiscalYear, Period, NombreArchivoImportado, IdUsuario, IdContrato)
	SELECT @DocType, @Reverse, @Reclass, @RefDoc, @DocCurrency, @Concept, @CompanyCode, @PostingDate, @RequestedBy, @FiscalYear, @Period, @NombreArchivoImportado, @IdUsuario, @IdContrato
	
	select Scope_Identity()
END


