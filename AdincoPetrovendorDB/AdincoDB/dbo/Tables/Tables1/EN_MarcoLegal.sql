CREATE TABLE [dbo].[EN_MarcoLegal] (
    [IdMarcoLegal]     INT            IDENTITY (10000, 1) NOT NULL,
    [MarcoLegal]       VARCHAR (8000) NULL,
    [IsInterno]        BIT            NULL,
    [CreadoPor]        INT            NULL,
    [ModificadoPor]    INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    [ModificadoEn]     DATETIME       NULL,
    [Activo]           BIT            NULL,
    [BitJOA]           BIT            NULL,
    [MarcoLegalIngles] VARCHAR (8000) NULL,
    [Alias] VARCHAR(1000) NULL, 
    CONSTRAINT [PK_EN_MarcoLegal] PRIMARY KEY CLUSTERED ([IdMarcoLegal] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_MarcoLegal_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [fk_MarcoLegal_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

go
create index IX_EN_MarcoLegal			on	EN_MarcoLegal(IdMarcoLegal)