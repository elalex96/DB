
CREATE TABLE PV_PerfilPalabraClave(
Id INT IDENTITY(1,1) NOT NULL,
IdCategoria INT NOT NULL,
PalabraClave VARCHAR(MAX) NOT NULL,
Activo BIT NOT NULL,
IdProveedor INT NOT NULL,
CreadoPor INT NOT NULL, 
CreadoEl DATETIME NOT NULL,
ModificadoPor INT NULL,
ModificadoEl DATETIME NULL,
CONSTRAINT [PK_PV_PerfilPalabraClave] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
CONSTRAINT [FK_PV_PerfilPalabraClave_S_Proveedor_IdProveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
)


GO
CREATE NONCLUSTERED INDEX [idxIdCategoria]
    ON [dbo].[PV_PerfilPalabraClave]([IdCategoria] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);
GO
CREATE NONCLUSTERED INDEX [idxIdProveedor]
    ON [dbo].[PV_PerfilPalabraClave]([IdProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);