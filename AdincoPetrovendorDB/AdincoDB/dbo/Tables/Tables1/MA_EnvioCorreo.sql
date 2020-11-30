CREATE TABLE [dbo].[MA_EnvioCorreo] (
    [IdEnvioCorreo]    INT            IDENTITY (1, 1) NOT NULL,
    [IdEnvioAdinco]    INT            NOT NULL,
    [IdCorreo]         INT            NOT NULL,
    [IdIdentificacion] NVARCHAR (MAX) NOT NULL,
    [EnviadoPor]       INT            NULL,
    [EnviadoEl]        SMALLDATETIME  NULL,
    CONSTRAINT [PK_MA_EnvioCorreo] PRIMARY KEY CLUSTERED ([IdEnvioCorreo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

