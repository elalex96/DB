CREATE TABLE [dbo].[AX_DOMICILIO] (
    [IdDomicilioAx]     NVARCHAR (200) NOT NULL,
    [IdDomicilioPetrov] INT            NULL,
    PRIMARY KEY CLUSTERED ([IdDomicilioAx] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

