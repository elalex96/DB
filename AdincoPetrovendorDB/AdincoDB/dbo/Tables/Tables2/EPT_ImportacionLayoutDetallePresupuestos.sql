CREATE TABLE [dbo].[EPT_ImportacionLayoutDetallePresupuestos]
(
    Id INT IDENTITY(1, 1) NOT NULL,
    ImportacionLayoutDetalleId INT NOT NULL,
    DocumentoFacturacionId INT NOT NULL,
    Presupuesto VARCHAR(100) NOT NULL,
    PresupuestoId INT NOT NULL,
    Activo BIT NOT NULL,
    CreadoEn DATETIME NOT NULL,
    CreadoPor INT NOT NULL,
    ModificadoEn DATETIME NULL,
    ModificadoPor INT NULL,
    CONSTRAINT [PK_EPT_ImportacionLayoutDetallePresupuestos]
        PRIMARY KEY (Id),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_EPT_ImportacionLayoutDetalle]
        FOREIGN KEY (ImportacionLayoutDetalleId)
        REFERENCES EPT_ImportacionLayoutDetalle (Id),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_CO_Presupuesto]
        FOREIGN KEY (PresupuestoId)
        REFERENCES CO_Presupuesto (IdPresupuesto),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_Creador]
        FOREIGN KEY (CreadoPor)
        REFERENCES AP_Usuario (UsuarioID),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_Modificador]
        FOREIGN KEY (ModificadoPor)
        REFERENCES AP_Usuario (UsuarioID)
)
