CREATE TABLE [dbo].[PR_ParametrosConfig] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]    NVARCHAR (200) NULL,
    [Valor_min] FLOAT (53)     NULL,
    [Valor_max] FLOAT (53)     NULL,
    [Activo]    INT            NULL,
    [Fecha]     DATETIME       NULL,
    CONSTRAINT [PK_PR_ParametrosConfig] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

