CREATE TABLE [dbo].[TA_EnvioCorreo] (
    [IdEnvioCorreo]    INT            IDENTITY (1, 1) NOT NULL,
    [IdEnvioAdinco]    INT            NOT NULL,
    [IdCorreo]         INT            NOT NULL,
    [IdIdentificacion] NVARCHAR (MAX) NOT NULL,
    [EnviadoPor]       INT            NULL,
    [EnviadoEl]        SMALLDATETIME  NULL,
    CONSTRAINT [PK_TA_EnvioCorreo] PRIMARY KEY CLUSTERED ([IdEnvioCorreo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_EnvioCorreo_TA_Correo] FOREIGN KEY ([IdCorreo]) REFERENCES [dbo].[TA_Correo] ([IdCorreo])
);

