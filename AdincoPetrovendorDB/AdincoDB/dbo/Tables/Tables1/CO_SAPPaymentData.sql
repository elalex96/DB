CREATE TABLE [dbo].[CO_SAPPaymentData] (
    [IdContrato]           INT           NOT NULL,
    [SourceAccount]        VARCHAR (20)  NOT NULL,
    [FinalAccount]         VARCHAR (20)  NOT NULL,
    [PaymentReference]     VARCHAR (10)  NOT NULL,
    [PaymentForm]          VARCHAR (2)   NOT NULL,
    [PaymentDate]          VARCHAR (10)  NOT NULL,
    [PaidAmount]           FLOAT (53)    NOT NULL,
    [Currency]             VARCHAR (5)   NOT NULL,
    [Concepto]             VARCHAR (50)  NOT NULL,
    [NumeroPolizaContable] VARCHAR (20)  NOT NULL,
    [PDF]                  VARCHAR (250) NOT NULL,
    [Interest]             FLOAT (53)    NOT NULL,
    [NamePayee]            VARCHAR (50)  NULL,
    [SAPVendorId]          VARCHAR (50)  NULL,
    [VendorBankName]       VARCHAR (50)  NULL,
    [IdTransferencia]      INT           NULL,
    [InvoiceNumber]        VARCHAR (20)  DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_CO_SAPPaymentData] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [SourceAccount] ASC, [FinalAccount] ASC, [PaymentReference] ASC, [PaymentDate] ASC, [PaidAmount] ASC, [InvoiceNumber] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPPaymentData_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_SAPPayment_FI_Transfer] FOREIGN KEY ([IdTransferencia]) REFERENCES [dbo].[FI_Transfer] ([IdTransferencia])
);


GO
create TRIGGER [dbo].[UpdateProformaPayment]
ON [Adinco].[dbo].CO_SAPPaymentData
AFTER INSERT,UPDATE
AS 
begin
	CREATE TABLE #SESPROFROMATEMP
	(
		ID INT IDENTITY(1,1),
		PROFORMA INT,
		SES NVARCHAR(50)
	);

	INSERT INTO #SESPROFROMATEMP
	SELECT
		PSES.IdPRESES,
		SES.SESNumber
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
	LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PSES.SAPVendorNumber
	LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
	LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber and 
									po.Plant = ses.Plant
	WHERE SES.SESNumber <> PSES.SESN and 
	ISNULL(SES.SESNumber,'') <> '' AND
	pses.IdEstatus IN (1,2)
	
	GROUP BY PSES.IdPRESES,
			 SES.SESNumber


	DECLARE @CONTPROFOR INT = (SELECT COUNT(IdPRESES) FROM Adinco.dbo.CO_SAPPRESES);
	DECLARE @CONT INT = 1;
	DECLARE @SESNUMBER NVARCHAR(50);

	WHILE @CONT < @CONTPROFOR
	BEGIN
	
		SET @SESNUMBER = (SELECT SES FROM #SESPROFROMATEMP WHERE ID = @CONT)

		UPDATE Adinco.dbo.CO_SAPPRESES
		SET SESN = @SESNUMBER
		WHERE IdPRESES IN (SELECT PROFORMA FROM #SESPROFROMATEMP WHERE ID = @CONT)

		SET @CONT = @CONT + 1;

	END
END