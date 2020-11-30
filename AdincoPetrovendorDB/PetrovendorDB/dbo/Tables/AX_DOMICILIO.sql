CREATE TABLE [dbo].[AX_DOMICILIO] (
    [IdDomicilioAx]     NVARCHAR (200) NOT NULL,
    [IdDomicilioPetrov] INT            NULL,
    PRIMARY KEY CLUSTERED ([IdDomicilioAx] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

