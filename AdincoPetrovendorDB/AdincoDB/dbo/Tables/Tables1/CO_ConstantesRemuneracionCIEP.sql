CREATE TABLE [dbo].[CO_ConstantesRemuneracionCIEP] (
    [IdConstantesRemuneracionCIEP] INT        IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                   INT        NULL,
    [Anio]                         INT        NULL,
    [ConstanteST240kbls]           FLOAT (53) NULL,
    [IPPj]                         FLOAT (53) NULL,
    [IPP0]                         FLOAT (53) NULL,
    [Tarifa]                       FLOAT (53) NULL,
    [TasaDescuento]                FLOAT (53) NULL,
    [ConstanteST]                  FLOAT (53) NULL,
    CONSTRAINT [PK_CO_ConstantesRemuneracionCIEP] PRIMARY KEY CLUSTERED ([IdConstantesRemuneracionCIEP] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ConstantesRemuneracionCIEP_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

