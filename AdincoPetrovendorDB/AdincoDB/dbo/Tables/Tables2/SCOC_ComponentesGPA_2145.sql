CREATE TABLE [dbo].[SCOC_ComponentesGPA_2145] (
    [IdComponente]  INT           NOT NULL,
    [NombreES]      VARCHAR (250) NULL,
    [NombreEN]      VARCHAR (250) NULL,
    [AbreviacionES] VARCHAR (15)  NULL,
    [AbreviacionEN] VARCHAR (15)  NULL,
    [Comentarios]   VARCHAR (250) NULL,
    CONSTRAINT [PK_SCOC_ComponentesGPA_2145] PRIMARY KEY CLUSTERED ([IdComponente] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

