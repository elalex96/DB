CREATE TABLE [dbo].[AP_Aspx] (
    [IdOpcionMenu]  INT            IDENTITY (1, 1) NOT NULL,
    [Archivos]      NVARCHAR (MAX) NULL,
    [ClaveMenu]     NVARCHAR (MAX) NULL,
    [Mapeado]       BIT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_AP_Aspx] PRIMARY KEY CLUSTERED ([IdOpcionMenu] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-20180626-132634]
    ON [dbo].[AP_Aspx]([IdOpcionMenu] ASC)
    INCLUDE([ClaveMenu]) WITH (STATISTICS_NORECOMPUTE = ON);

