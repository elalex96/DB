CREATE TABLE [dbo].[PR_Estado] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Clave]       VARCHAR (20)    NOT NULL,
    [Nombre]      VARCHAR (200)   NOT NULL,
    [Descripcion] NVARCHAR (2000) NULL,
    [Estatus]     TINYINT         NOT NULL,
    [Pais]        INT             NOT NULL,
    CONSTRAINT [PK_PR_Estado] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Estado_Pais] FOREIGN KEY ([Pais]) REFERENCES [dbo].[PR_Pais] ([Id])
);

