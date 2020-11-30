CREATE TABLE [dbo].[PC_Material] (
    [IdMaterialPC] INT            IDENTITY (10000, 1) NOT NULL,
    [CvMaterial]   FLOAT (53)     NULL,
    [TextoBreve]   NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    [CreapoEn]     DATETIME       NULL,
    CONSTRAINT [PK_PC_Material] PRIMARY KEY CLUSTERED ([IdMaterialPC] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

