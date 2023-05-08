CREATE TABLE [dbo].[CO_RegistroMarkupBitacora] (
    [Id]                             INT        IDENTITY (1, 1) NOT NULL,
    [IdRegistro]                     INT        NULL,
    [IdEstadoAnterior]               INT        NULL,
    [IdEstadoActual]                 INT        NULL,
    [MesEstadoPemexAnterior]         DATE       NULL,
    [MesEstadoPemexActual]           DATE       NULL,
    [CreadoEn]                       DATETIME   NULL,
    [CreadoPor]                      INT        NULL,
    [ImporteEstimadoParcialAnterior] FLOAT (53) NULL,
    [ImporteEstimadoParcialActual]   FLOAT (53) NULL,
    FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

