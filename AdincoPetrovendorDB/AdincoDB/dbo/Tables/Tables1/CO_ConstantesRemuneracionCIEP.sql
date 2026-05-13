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
    [CreadoPor]                    INT        NULL,
    [CreadoEn]                     DATETIME   NULL,
    [ModificadoPor]                INT        NULL,
    [ModificadoEn]                 DATETIME   NULL,
    CONSTRAINT [PK_CO_ConstantesRemuneracionCIEP] PRIMARY KEY CLUSTERED ([IdConstantesRemuneracionCIEP] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ConstantesRemuneracionCIEP_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ConstantesRemuneracionCIEP_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ConstantesRemuneracionCIEP_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

