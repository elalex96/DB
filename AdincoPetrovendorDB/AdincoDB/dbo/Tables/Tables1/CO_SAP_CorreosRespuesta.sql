CREATE TABLE [dbo].[CO_SAP_CorreosRespuesta] (
    [IdContratista] INT           NOT NULL,
    [Correo]        VARCHAR (100) NOT NULL,
    [CreadoEl]      DATETIME      NULL,
    CONSTRAINT [PK_CO_SAP_CorreosRespuesta] PRIMARY KEY CLUSTERED ([IdContratista] ASC, [Correo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAP_CorreosRespuesta_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

