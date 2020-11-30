CREATE TABLE [dbo].[PV_PaisRepublica] (
    [id]   INT           NOT NULL,
    [pais] VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Cat_Pais] PRIMARY KEY CLUSTERED ([id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

