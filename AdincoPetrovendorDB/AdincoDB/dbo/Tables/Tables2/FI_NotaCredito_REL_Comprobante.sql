USE [Adinco];
GO

IF OBJECT_ID('[dbo].[FI_NotaCredito_REL_Comprobantes]', 'U') IS NOT NULL
    DROP TABLE [dbo].[FI_NotaCredito_REL_Comprobantes];
GO

CREATE TABLE FI_NotaCredito_REL_Comprobantes
(
    IdNotaCredito INT NOT NULL,
    IdComprobanteRelacionado INT NOT NULL,
    Monto MONEY NOT NULL,
    CreadoPor INT NOT NULL,
    CreadoEl DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_FI_NotaCredito_REL_Comprobantes PRIMARY KEY (IdNotaCredito, IdComprobanteRelacionado),

    CONSTRAINT FK_FacturaRELNC_IdComprobante FOREIGN KEY (IdNotaCredito)
        REFERENCES FI_PedimentoComprobante(IdPedimentoComprobante),

    CONSTRAINT FK_FacturaRELNC_IdComprobanteRelacionado FOREIGN KEY (IdComprobanteRelacionado)
        REFERENCES FI_PedimentoComprobante(IdPedimentoComprobante),

    CONSTRAINT FK_FacturaRELNC_CreadoPor FOREIGN KEY (CreadoPor)
        REFERENCES AP_Usuario(UsuarioID)
);
GO
