CREATE TABLE [dbo].[EX_Usuario] (
    [idUsuarioExt]    INT           IDENTITY (10001, 1) NOT NULL,
    [Nombre]          VARCHAR (MAX) NULL,
    [Apellido]        VARCHAR (MAX) NULL,
    [Dependencia]     VARCHAR (MAX) NULL,
    [Justificacion]   VARCHAR (MAX) NULL,
    [Vigencia]        SMALLDATETIME NULL,
    [UsuarioRegistro] VARCHAR (MAX) NULL,
    [FechaRegistro]   SMALLDATETIME NULL,
    [Clave]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK__EX_Usuar__4B1879D42E78C987] PRIMARY KEY CLUSTERED ([idUsuarioExt] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

