CREATE TYPE [dbo].[SubTareas] AS TABLE (
    [IdServicio] INT            NULL,
    [Volumen]    FLOAT (53)     NULL,
    [MONac]      FLOAT (53)     NULL,
    [MOExt]      FLOAT (53)     NULL,
    [BSNac]      FLOAT (53)     NULL,
    [BSExt]      FLOAT (53)     NULL,
    [Pozos]      NVARCHAR (MAX) NULL);

