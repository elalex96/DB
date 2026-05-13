CREATE TABLE [dbo].[PV_Contacto] (
    [ContactoID] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]     VARCHAR (MAX) NOT NULL,
    [Apellidos]  VARCHAR (MAX) NOT NULL,
    [Email]      VARCHAR (250) NOT NULL,
    [Telefono]   VARCHAR (50)  NOT NULL,
    [web]        VARCHAR (MAX) NOT NULL,
    [EmpresaID]  INT           NOT NULL,
    CONSTRAINT [PK_Contacto] PRIMARY KEY CLUSTERED ([ContactoID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Contacto_Empresa] FOREIGN KEY ([EmpresaID]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);

