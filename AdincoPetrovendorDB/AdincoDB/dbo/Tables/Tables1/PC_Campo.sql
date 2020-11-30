CREATE TABLE [dbo].[PC_Campo] (
    [IdCampo]          INT            IDENTITY (10000, 1) NOT NULL,
    [CvCampo]          NVARCHAR (10)  NULL,
    [DescripcionCampo] NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    CONSTRAINT [PK_PC_Campo] PRIMARY KEY CLUSTERED ([IdCampo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

